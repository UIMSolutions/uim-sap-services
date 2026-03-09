module uim.sap.buh.service;

import uim.sap.buh;

mixin(ShowModule!());

@safe:

class BUHService : SAPService {
  mixin(SAPServiceTemplate!BUHService);

  private BUHStore _store;

  this(BUHConfig config) {
    config.validate();
    _config = config;
    _store = new BUHStore;
  }

  override Json health() {
    Json payload = super.health();
    payload["apis"] = cast(long)_store.listApis().length;
    payload["products"] = cast(long)_store.listProducts().length;
    payload["subscriptions"] = cast(long)_store.listSubscriptions().length;
    return payload;
  }

  Json createApi(Json request) {
    auto api = apiFromJson(request);
    if (api.name.length == 0) {
      throw new BUHValidationException("API name is required");
    }
    if (api.apiVersion.length == 0) {
      throw new BUHValidationException("API version is required");
    }
    if (api.provider.length == 0) {
      api.provider = "SAP";
    }

    auto created = _store.createApi(api);
    return created.toJson();
  }

  Json listApis() {
    Json resources = _store.listApis().map!(api => api.toJson).array.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listApis().length;
    return payload;
  }

  Json getApi(string id) {
    auto api = _store.getApi(id);
    if (api.id.length == 0) {
      throw new BUHNotFoundException("API", id);
    }
    return api.toJson();
  }

  Json createProduct(Json request) {
    auto product = productFromJson(request);
    if (product.name.length == 0) {
      throw new BUHValidationException("Product name is required");
    }

    foreach (apiId; product.apiIds) {
      if (!_store.hasApi(apiId)) {
        throw new BUHNotFoundException("API", apiId);
      }
    }

    auto created = _store.createProduct(product);
    return created.toJson();
  }

  Json listProducts() {
    Json resources = _store.listProducts().map!(product => product.toJson).array.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listProducts().length;
    return payload;
  }

  Json createSubscription(Json request) {
    auto subscription = subscriptionFromJson(request);
    if (subscription.apiId.length == 0) {
      throw new BUHValidationException("api_id is required");
    }
    if (subscription.applicationName.length == 0) {
      throw new BUHValidationException("application_name is required");
    }
    if (!_store.hasApi(subscription.apiId)) {
      throw new BUHNotFoundException("API", subscription.apiId);
    }
    if (subscription.plan.length == 0) {
      subscription.plan = "default";
    }

    auto created = _store.createSubscription(subscription);
    return created.toJson();
  }

  Json listSubscriptions() {
    Json resources = _store.listSubscriptions().map!(subscription => subscription.toJson).array.toJson();

    Json payload = Json.emptyObject;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)_store.listSubscriptions().length;
    return payload;
  }
}
