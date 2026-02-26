/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.smg.store;

import core.sync.mutex : Mutex;

import std.datetime : Clock;
import std.datetime : SysTime;
import std.typecons : Nullable;

import uim.sap.smg.models;

class SMGStore {
    private SMGSite[string] _sites;
    private SMGSubaccountSettings[string] _subaccountSettings;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    SMGSite upsertSite(SMGSite site) {
        synchronized (_lock) {
            auto key = scopedKey(site.tenantId, "site", site.siteId);
            if (auto existing = key in _sites) site.createdAt = existing.createdAt;
            _sites[key] = site;
            return site;
        }
    }

    SMGSite[] listSites(string tenantId) {
        SMGSite[] values;
        synchronized (_lock) {
            foreach (key, value; _sites) if (belongsToTenant(key, tenantId)) values ~= value;
        }
        return values;
    }

    Nullable!SMGSite getSite(string tenantId, string siteId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "site", siteId);
            if (auto value = key in _sites) return Nullable!SMGSite(*value);
            return Nullable!SMGSite.init;
        }
    }

    bool deleteSite(string tenantId, string siteId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "site", siteId);
            if ((key in _sites) is null) return false;
            _sites.remove(key);

            auto settingsKey = scopedKey(tenantId, "subaccount", "settings");
            if (auto settings = settingsKey in _subaccountSettings) {
                if (settings.defaultSiteId == siteId) {
                    settings.defaultSiteId = "";
                    settings.updatedAt = Clock.currTime();
                    _subaccountSettings[settingsKey] = *settings;
                }
            }
            return true;
        }
    }

    SMGSubaccountSettings upsertSubaccountSettings(SMGSubaccountSettings settings) {
        synchronized (_lock) {
            auto key = scopedKey(settings.tenantId, "subaccount", "settings");
            _subaccountSettings[key] = settings;
            return settings;
        }
    }

    Nullable!SMGSubaccountSettings getSubaccountSettings(string tenantId) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "subaccount", "settings");
            if (auto value = key in _subaccountSettings) return Nullable!SMGSubaccountSettings(*value);
            return Nullable!SMGSubaccountSettings.init;
        }
    }

    private bool belongsToTenant(string key, string tenantId) {
        auto prefix = tenantId ~ ":";
        return key.length >= prefix.length && key[0 .. prefix.length] == prefix;
    }

    private string scopedKey(string tenantId, string kind, string id) {
        return tenantId ~ ":" ~ kind ~ ":" ~ id;
    }
}
