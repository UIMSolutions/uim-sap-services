module uim.sap.datasphere.store;

import core.sync.mutex : Mutex;
import std.conv : to;

import vibe.data.json : Json;

import uim.sap.datasphere.models;

class DatasphereStore {
    private DATSpace[string] _spaces;
    private DATDataModel[string] _dataModels;
    private DATBusinessModel[string] _businessModels;
    private DATIntegrationConnection[string] _connections;
    private DATGovernanceAsset[string] _catalogAssets;
    private DATGlossaryTerm[string] _glossaryTerms;
    private DATKpi[string] _kpis;
    private RowPolicy[string] _rowPolicies;
    private DATAuditEvent[][string] _auditEvents;
    private TenantAdminState _tenantAdminState;

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

    DATSpace[] listSpaces(string tenantId) {
        DATSpace[] values;
        synchronized (_lock) {
            foreach (key, value; _spaces) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getSpace(string tenantId, string spaceId, out DATSpace result) {
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

    DATDataModel[] listDataModels(string tenantId) {
        DATDataModel[] values;
        synchronized (_lock) {
            foreach (key, value; _dataModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getDataModel(string tenantId, string modelId, out DATDataModel result) {
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

    DATBusinessModel[] listBusinessModels(string tenantId) {
        DATBusinessModel[] values;
        synchronized (_lock) {
            foreach (key, value; _businessModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getBusinessModel(string tenantId, string modelId, out DATBusinessModel result) {
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

    DATIntegrationConnection[] listConnections(string tenantId) {
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

    DATGovernanceAsset[] listAssets(string tenantId) {
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

    DATGlossaryTerm[] listTerms(string tenantId) {
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

    DATKpi[] listKPIs(string tenantId) {
        DATKpi[] values;
        synchronized (_lock) {
            foreach (key, value; _kpis) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    RowPolicy upsertRowPolicy(RowPolicy item) {
        synchronized (_lock) {
            _rowPolicies[scopedKey(item.tenantId, "policy", item.policyId)] = item;
            return item;
        }
    }

    RowPolicy[] listRowPolicies(string tenantId) {
        RowPolicy[] values;
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

    DATAuditEvent[] listAuditEvents(string tenantId) {
        synchronized (_lock) {
            if (auto events = tenantId in _auditEvents) {
                return (*events).dup;
            }
        }
        return [];
    }

    TenantAdminState upsertTenantState(TenantAdminState state) {
        synchronized (_lock) {
            _tenantAdminState = state;
            return _tenantAdminState;
        }
    }

    TenantAdminState getTenantState() {
        synchronized (_lock) {
            return _tenantAdminState;
        }
    }

    private string scopedKey(string tenantId, string scopePart, string id) {
        return tenantId ~ ":" ~ scopePart ~ ":" ~ id;
    }

    private bool belongsTo(string key, string tenantId) {
        return key.length > tenantId.length + 1 && key[0 .. tenantId.length] == tenantId && key[tenantId.length] == ':';
    }
}
