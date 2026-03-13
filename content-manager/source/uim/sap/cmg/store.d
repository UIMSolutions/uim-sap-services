/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cmg.store;

import core.sync.mutex : Mutex;

import uim.sap.cmg;

mixin(ShowModule!());

@safe:

class CMGStore : SAPStore {
    private CMGContentItem[string] _items;
    private CMGContentProvider[string] _providers;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    CMGContentItem upsertItem(CMGContentItem item) {
        synchronized (_lock) {
            auto key = scopedItemKey(item.tenantId, item.contentType, item.itemId);
            if (auto existing = key in _items) item.createdAt = existing.createdAt;
            _items[key] = item;
            return item;
        }
    }

    CMGContentItem[] listItems(string tenantId, string contentType) {
        CMGContentItem[] values;
        synchronized (_lock) {
            auto prefix = tenantId ~ ":item:" ~ contentType ~ ":";
            foreach (key, value; _items) {
                if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
            }
        }
        return values;
    }

    Nullable!CMGContentProvider getProvider(string tenantId, string providerId) {
        synchronized (_lock) {
            auto key = scopedProviderKey(tenantId, providerId);
            if (auto value = key in _providers) return Nullable!CMGContentProvider(*value);
            return Nullable!CMGContentProvider.init;
        }
    }

    CMGContentProvider upsertProvider(CMGContentProvider provider) {
        synchronized (_lock) {
            auto key = scopedProviderKey(provider.tenantId, provider.providerId);
            if (auto existing = key in _providers) provider.createdAt = existing.createdAt;
            _providers[key] = provider;
            return provider;
        }
    }

    CMGContentProvider[] listProviders(string tenantId) {
        CMGContentProvider[] values;
        synchronized (_lock) {
            auto prefix = tenantId ~ ":provider:";
            foreach (key, value; _providers) {
                if (key.length >= prefix.length && key[0 .. prefix.length] == prefix) values ~= value;
            }
        }
        return values;
    }

    private string scopedItemKey(string tenantId, string contentType, string itemId) {
        return tenantId ~ ":item:" ~ contentType ~ ":" ~ itemId;
    }

    private string scopedProviderKey(string tenantId, string providerId) {
        return tenantId ~ ":provider:" ~ providerId;
    }
}
