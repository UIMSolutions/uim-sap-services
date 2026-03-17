module uim.sap.service.helpers.optional;

import uim.sap.service;

mixin(ShowModule!());

@safe:

bool optionalBoolean(Json data, string key, bool fallback) const {
  if (!(key in data) || data[key].isNull)
    return fallback;

  requiredBooleanType(data, key);
  return data[key].get!bool;
}

string optionalString(Json data, string key, string fallback) const {
  if (!(key in data) || data[key].isNull)
    return fallback;

  requiredStringType(data, key);
  return data[key].get!string;
}

string optionalObject(Json data, string key, Json fallback = Json.emptyObject) const {
  if (!(key in data) || data[key].isNull) {
    return fallback;
  }

  requiredObjectType(data, key);
  return data[key];
}
