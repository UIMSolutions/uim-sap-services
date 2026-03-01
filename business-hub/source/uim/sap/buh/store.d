/**
 * In-memory store for BUH resources
 */
module uim.sap.buh.store;

import core.sync.mutex : Mutex;

import uim.sap.buh.models;

class BUHStore : SAPStore {
    private BUHApi[string] _apis;
    private BUHProduct[string] _products;
    private BUHSubscription[string] _subscriptions;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    BUHApi createApi(BUHApi api) {
        synchronized (_lock) {
            _apis[api.id] = api;
            return api;
        }
    }

    BUHProduct createProduct(BUHProduct product) {
        synchronized (_lock) {
            _products[product.id] = product;
            return product;
        }
    }

    BUHSubscription createSubscription(BUHSubscription subscription) {
        synchronized (_lock) {
            _subscriptions[subscription.id] = subscription;
            return subscription;
        }
    }

    BUHApi[] listApis() {
        BUHApi[] values;
        synchronized (_lock) {
            foreach (entry; _apis.byValue) {
                values ~= entry;
            }
        }
        return values;
    }

    BUHProduct[] listProducts() {
        BUHProduct[] values;
        synchronized (_lock) {
            foreach (entry; _products.byValue) {
                values ~= entry;
            }
        }
        return values;
    }

    BUHSubscription[] listSubscriptions() {
        BUHSubscription[] values;
        synchronized (_lock) {
            foreach (entry; _subscriptions.byValue) {
                values ~= entry;
            }
        }
        return values;
    }

    bool hasApi(string id) {
        synchronized (_lock) {
            return (id in _apis) !is null;
        }
    }

    BUHApi getApi(string id) {
        synchronized (_lock) {
            if (auto ptr = id in _apis) {
                return *ptr;
            }
        }
        return BUHApi.init;
    }
}
