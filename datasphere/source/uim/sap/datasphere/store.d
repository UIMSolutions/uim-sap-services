/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.datasphere.store;

import core.sync.mutex : Mutex;

import uim.sap.datasphere;

mixin(ShowModule!());

@safe:

class DSPStore : SAPStore {
    private DATSpace[string] _spaces;
    private DATDataModel[string] _dataModels;
    private DATBusinessModel[string] _businessModels;
    private DATIntegrationConnection[string] _connections;
    private DATGovernanceAsset[string] _catalogAssets;
    private DATGlossaryTerm[string] _glossaryTerms;
    private DATKpi[string] _kpis;
    private DATRowPolicy[string] _rowPolicies;
    private DATAuditEvent[][string] _auditEvents;
    private DATTenantAdminState _tenantAdminState;

    private Mutex _lock;
    private long _idCounter;

    this() {
        _lock = new Mutex;
        _tenantAdminState.tenantName = "default";
        _tenantAdminState.connectivityPrepared = false;
        _tenantAdminState.maintenanceMode = false;
        _tenantAdminState.lastMaintenance = "never";
        _tenantAdminState.custom = Json.emptyObject;
    }

    string nextId(string prefix) {
        synchronized (_lock) {
            ++_idCounter;
            return prefix ~ "-" ~ _idCounter.to!string;
        }
    }

    DATSpace upsertSpace(DATSpace item) {
        synchronized (_lock) {
            _spaces[scopedKey(item.tenantId, "space", item.spaceId)] = item;
            return item;
        }
    }

    DATSpace[] listSpaces(UUID tenantId) {
        DATSpace[] values;
        synchronized (_lock) {
            foreach (key, value; _spaces) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getSpace(UUID tenantId, string spaceId, out DATSpace result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "space", spaceId);
            if (auto existing = key in _spaces) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    DATDataModel upsertDataModel(DATDataModel item) {
        synchronized (_lock) {
            _dataModels[scopedKey(item.tenantId, "dmodel", item.modelId)] = item;
            return item;
        }
    }

    DATDataModel[] listDataModels(UUID tenantId) {
        DATDataModel[] values;
        synchronized (_lock) {
            foreach (key, value; _dataModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getDataModel(UUID tenantId, string modelId, out DATDataModel result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "dmodel", modelId);
            if (auto existing = key in _dataModels) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    DATBusinessModel upsertBusinessModel(DATBusinessModel item) {
        synchronized (_lock) {
            _businessModels[scopedKey(item.tenantId, "bmodel", item.modelId)] = item;
            return item;
        }
    }

    DATBusinessModel[] listBusinessModels(UUID tenantId) {
        DATBusinessModel[] values;
        synchronized (_lock) {
            foreach (key, value; _businessModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getBusinessModel(UUID tenantId, string modelId, out DATBusinessModel result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "bmodel", modelId);
            if (auto existing = key in _businessModels) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    DATIntegrationConnection upsertConnection(DATIntegrationConnection item) {
        synchronized (_lock) {
            _connections[scopedKey(item.tenantId, "conn", item.connectionId)] = item;
            return item;
        }
    }

    DATIntegrationConnection[] listConnections(UUID tenantId) {
        DATIntegrationConnection[] values;
        synchronized (_lock) {
            foreach (key, value; _connections) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    DATGovernanceAsset upsertAsset(DATGovernanceAsset item) {
        synchronized (_lock) {
            _catalogAssets[scopedKey(item.tenantId, "asset", item.assetId)] = item;
            return item;
        }
    }

    DATGovernanceAsset[] listAssets(UUID tenantId) {
        DATGovernanceAsset[] values;
        synchronized (_lock) {
            foreach (key, value; _catalogAssets) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    DATGlossaryTerm upsertTerm(DATGlossaryTerm item) {
        synchronized (_lock) {
            _glossaryTerms[scopedKey(item.tenantId, "term", item.termId)] = item;
            return item;
        }
    }

    DATGlossaryTerm[] listTerms(UUID tenantId) {
        DATGlossaryTerm[] values;
        synchronized (_lock) {
            foreach (key, value; _glossaryTerms) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    DATKpi upsertKPI(DATKpi item) {
        synchronized (_lock) {
            _kpis[scopedKey(item.tenantId, "kpi", item.kpiId)] = item;
            return item;
        }
    }

    DATKpi[] listKPIs(UUID tenantId) {
        DATKpi[] values;
        synchronized (_lock) {
            foreach (key, value; _kpis) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    DATRowPolicy upsertRowPolicy(DATRowPolicy item) {
        synchronized (_lock) {
            _rowPolicies[scopedKey(item.tenantId, "policy", item.policyId)] = item;
            return item;
        }
    }

    DATRowPolicy[] listRowPolicies(UUID tenantId) {
        DATRowPolicy[] values;
        synchronized (_lock) {
            foreach (key, value; _rowPolicies) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    DATAuditEvent addAuditEvent(DATAuditEvent item) {
        synchronized (_lock) {
            _auditEvents[item.tenantId] ~= item;
            return item;
        }
    }

    DATAuditEvent[] listAuditEvents(UUID tenantId) {
        synchronized (_lock) {
            if (auto events = tenantId in _auditEvents) {
                return (*events).dup;
            }
        }
        return null;
    }

    DATTenantAdminState upsertTenantState(DATTenantAdminState state) {
        synchronized (_lock) {
            _tenantAdminState = state;
            return _tenantAdminState;
        }
    }

    DATTenantAdminState getTenantState() {
        synchronized (_lock) {
            return _tenantAdminState;
        }
    }

    private string scopedKey(UUID tenantId, string scopePart, string id) {
        return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
    }

    private bool belongsTo(string key, UUID tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }
}
