module uim.sap.dqm.service;

import uim.sap.dqm;

mixin(ShowModule!());

@safe:


class DQMService : SAPService {
  private DQMStore _store;

  this(DQMConfig config) {
    super(config);
    _store = new DQMStore;
  }

  override Json health() {
    DQMConfig cfg = cast(DQMConfig)_config;

    Json healthInfo = super.health();
    healthInfo["geodata_records"] = cast(long)_store.records().length;
    return healthInfo;
  }

  Json cleanseAddress(Json request) {
    if (!("address" in request) || !request["address"].isObject) {
      throw new DQMValidationException("address object is required");
    }

    DQMConfig cfg = cast(DQMConfig)_config;
    auto original = addressFromJson(request["address"], cfg.defaultCountry);
    validateAddress(original);

    bool uppercaseCity = false;
    bool keepLine2 = true;
    if ("preferences" in request && request["preferences"].isObject) {
      auto pref = request["preferences"];
      if ("uppercase_city" in pref && pref["uppercase_city"].isBoolean)
        uppercaseCity = pref["uppercase_city"].get!bool;
      if ("keep_line2" in pref && pref["keep_line2"].isBoolean)
        keepLine2 = pref["keep_line2"].get!bool;
    }

    auto standardized = standardizedAddress(original, uppercaseCity, keepLine2);
    auto searchKey = standardized.line1 ~ " " ~ standardized.city;
    auto proposals = _store.findAddressMatches(searchKey, standardized.country);

    Json suggestionList = Json.emptyArray;
    foreach (proposal; proposals) {
      suggestionList ~= proposal.address.toJson();
    }

    Json corrections = Json.emptyObject;
    corrections["line1_changed"] = original.line1 != standardized.line1;
    corrections["city_changed"] = original.city != standardized.city;
    corrections["postal_code_changed"] = original.postalCode != standardized.postalCode;
    corrections["country_changed"] = original.country != standardized.country;

    Json payload = Json.emptyObject;
    payload["valid"] = true;
    payload["ambiguous"] = proposals.length > 1;
    payload["input"] = original.toJson();
    payload["standardized"] = standardized.toJson();
    payload["suggestions"] = suggestionList;
    payload["corrections"] = corrections;
    return payload;
  }

  Json geocode(Json request) {
    if (!("address" in request) || !request["address"].isObject) {
      throw new DQMValidationException("address object is required");
    }

    DQMConfig cfg = cast(DQMConfig)_config;
    auto address = addressFromJson(request["address"], cfg.defaultCountry);
    validateAddress(address);

    auto query = address.line1 ~ " " ~ address.city;
    auto matches = _store.findAddressMatches(query, address.country);
    if (matches.length == 0) {
      throw new DQMNotFoundException("Address geocode", query);
    }

    auto best = matches[0];
    Json alternatives = Json.emptyArray;
    foreach (candidate; matches) {
      alternatives ~= candidate.toJson();
    }

    Json payload = Json.emptyObject;
    payload["address"] = best.address.toJson();
    payload["point"] = best.point.toJson();
    payload["ambiguous"] = matches.length > 1;
    payload["proposed_addresses"] = alternatives;
    return payload;
  }

  Json reverseGeocode(Json request) {
    auto latitude = getNumber(request, "latitude");
    auto longitude = getNumber(request, "longitude");

    size_t limit = 3;
    if ("limit" in request && request["limit"].isInteger) {
      auto parsed = request["limit"].get!long;
      if (parsed > 0)
        limit = cast(size_t)parsed;
    }

    auto nearest = _store.nearest(latitude, longitude, limit);
    Json addresses = Json.emptyArray;
    foreach (record; nearest) {
      Json item = Json.emptyObject;
      item["address"] = record.address.toJson();
      item["point"] = record.point.toJson();
      addresses ~= item;
    }

    Json payload = Json.emptyObject;
    payload["query"] = Json.emptyObject;
    payload["query"]["latitude"] = latitude;
    payload["query"]["longitude"] = longitude;
    payload["nearest_addresses"] = addresses;
    payload["total_results"] = cast(long)addresses.length;
    return payload;
  }

  Json suggestAddresses(Json request) {
    if (!("query" in request) || !request["query"].isString || request["query"].get!string.length == 0) {
      throw new DQMValidationException("query is required");
    }

    auto query = request["query"].get!string;
    DQMConfig cfg = cast(DQMConfig)_config;
    auto country = cfg.defaultCountry;
    if ("country" in request && request["country"].isString && request["country"].get!string.length > 0) {
      country = request["country"].get!string;
    }

    size_t limit = 5;
    if ("limit" in request && request["limit"].isInteger) {
      auto parsed = request["limit"].get!long;
      if (parsed > 0)
        limit = cast(size_t)parsed;
    }

    auto suggestions = _store.suggest(query, toLower(country), limit);
    Json resources = Json.emptyArray;
    foreach (suggestion; suggestions) {
      resources ~= suggestion.address.toJson();
    }

    Json payload = Json.emptyObject;
    payload["query"] = query;
    payload["country"] = country;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  private double getNumber(Json request, string fieldName) {
    if (!(fieldName in request)) {
      throw new DQMValidationException(fieldName ~ " is required");
    }
    if (request[fieldName].isFloat) {
      return request[fieldName].get!double;
    }
    if (request[fieldName].isInteger) {
      return cast(double)request[fieldName].get!long;
    }
    throw new DQMValidationException(fieldName ~ " must be numeric");
  }

  private void validateAddress(DQMAddress address) {
    if (address.line1.length == 0)
      throw new DQMValidationException("address.line1 is required");
    if (address.city.length == 0)
      throw new DQMValidationException("address.city is required");
    if (address.country.length == 0)
      throw new DQMValidationException("address.country is required");
  }
}
