/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cps.store;

import core.sync.mutex : Mutex;

import uim.sap.cps;

mixin(ShowModule!());

@safe:

class CPSStore : SAPStore {
    private CPSSite[string] _sites;
    private CPSAdminSettings[string] _admin;
    private CPSContentItem[string] _content;
    private CPSLaunchpadModule[string] _launchpad;
    private CPSContentProvider[string] _providers;
    private Mutex _lock;

    this() { _lock = new Mutex; }

    CPSSite upsertSite(CPSSite site) {
        synchronized (_lock) {
            auto key = scopedKey(site.tenantId, "site", site.siteId);
            if (auto existing = key in _sites) site.createdAt = existing.createdAt;
            _sites[key] = site;
            return site;
        }
    }

    CPSSite getSite(UUID tenantId, string siteId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "site", siteId);
            if (auto value = key in _sites) return *value;
        }
        return CPSSite.init;
    }

    bool deleteSite(UUID tenantId, string siteId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "site", siteId);
            if ((key in _sites) is null) return false;
            _sites.remove(key);
            return true;
        }
    }

    CPSSite[] listSites(UUID tenantId) {
        CPSSite[] values;
        synchronized (_lock) {
            foreach (key, value; _sites) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    CPSAdminSettings upsertAdmin(CPSAdminSettings settings) {
        synchronized (_lock) {
            _admin[scopedKey(settings.tenantId, "admin", "default")] = settings;
            return settings;
        }
    }

    CPSAdminSettings getAdmin(UUID tenantId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "admin", "default");
            if (auto value = key in _admin) return *value;
        }
        return CPSAdminSettings.init;
    }

    CPSContentItem upsertContent(CPSContentItem item) {
        synchronized (_lock) {
            _content[scopedKey(item.tenantId, item.itemType, item.itemId)] = item;
            return item;
        }
    }

    CPSContentItem[] listContent(UUID tenantId, string itemType) {
        CPSContentItem[] values;
        synchronized (_lock) {
            foreach (key, value; _content) {
                if (belongsTo(key, tenantId) && keyContainsType(key, itemType)) values ~= value;
            }
        }
        return values;
    }

    CPSLaunchpadModule upsertLaunchpad(CPSLaunchpadModule launchpadModule) {
        synchronized (_lock) {
            _launchpad[scopedKey(launchpadModule.tenantId, "launchpad", launchpadModule.moduleId)] = launchpadModule;
            return launchpadModule;
        }
    }

    CPSLaunchpadModule[] listLaunchpad(UUID tenantId) {
        CPSLaunchpadModule[] values;
        synchronized (_lock) {
            foreach (key, value; _launchpad) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    CPSContentProvider upsertProvider(CPSContentProvider provider) {
        synchronized (_lock) {
            _providers[scopedKey(provider.tenantId, "provider", provider.providerId)] = provider;
            return provider;
        }
    }

    CPSContentProvider getProvider(UUID tenantId, string providerId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "provider", providerId);
            if (auto value = key in _providers) return *value;
        }
        return CPSContentProvider.init;
    }

    CPSContentProvider[] listProviders(UUID tenantId) {
        CPSContentProvider[] values;
        synchronized (_lock) {
            foreach (key, value; _providers) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    private string scopedKey(UUID tenantId, string scopePart, string id) {
        return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
    }

    private bool belongsTo(string key, UUID tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }

    private bool keyContainsType(string key, string itemType) {
        return key.length > 0 && itemType.length > 0 && key.canFind(":" ~ itemType ~ ":");
    }
}
