module uim.sap.datasphere.store;

import core.sync.mutex : Mutex;
import std.conv : to;

import vibe.data.json : Json;

import uim.sap.datasphere.models;

class DatasphereStore {
    private Space[string] _spaces;
    private DataModel[string] _dataModels;
    private BusinessModel[string] _businessModels;
    private IntegrationConnection[string] _connections;
    private GovernanceAsset[string] _catalogAssets;
    private GlossaryTerm[string] _glossaryTerms;
    private KPI[string] _kpis;
    private RowPolicy[string] _rowPolicies;
    private AuditEvent[][string] _auditEvents;
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

    Space upsertSpace(Space item) {
        synchronized (_lock) {
            _spaces[scopedKey(item.tenantId, "space", item.spaceId)] = item;
            return item;
        }
    }

    Space[] listSpaces(string tenantId) {
        Space[] values;
        synchronized (_lock) {
            foreach (key, value; _spaces) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getSpace(string tenantId, string spaceId, out Space result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "space", spaceId);
            if (auto existing = key in _spaces) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    DataModel upsertDataModel(DataModel item) {
        synchronized (_lock) {
            _dataModels[scopedKey(item.tenantId, "dmodel", item.modelId)] = item;
            return item;
        }
    }

    DataModel[] listDataModels(string tenantId) {
        DataModel[] values;
        synchronized (_lock) {
            foreach (key, value; _dataModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getDataModel(string tenantId, string modelId, out DataModel result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "dmodel", modelId);
            if (auto existing = key in _dataModels) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    BusinessModel upsertBusinessModel(BusinessModel item) {
        synchronized (_lock) {
            _businessModels[scopedKey(item.tenantId, "bmodel", item.modelId)] = item;
            return item;
        }
    }

    BusinessModel[] listBusinessModels(string tenantId) {
        BusinessModel[] values;
        synchronized (_lock) {
            foreach (key, value; _businessModels) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    bool getBusinessModel(string tenantId, string modelId, out BusinessModel result) {
        synchronized (_lock) {
            auto key = scopedKey(tenantId, "bmodel", modelId);
            if (auto existing = key in _businessModels) {
                result = *existing;
                return true;
            }
        }
        return false;
    }

    IntegrationConnection upsertConnection(IntegrationConnection item) {
        synchronized (_lock) {
            _connections[scopedKey(item.tenantId, "conn", item.connectionId)] = item;
            return item;
        }
    }

    IntegrationConnection[] listConnections(string tenantId) {
        IntegrationConnection[] values;
        synchronized (_lock) {
            foreach (key, value; _connections) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    GovernanceAsset upsertAsset(GovernanceAsset item) {
        synchronized (_lock) {
            _catalogAssets[scopedKey(item.tenantId, "asset", item.assetId)] = item;
            return item;
        }
    }

    GovernanceAsset[] listAssets(string tenantId) {
        GovernanceAsset[] values;
        synchronized (_lock) {
            foreach (key, value; _catalogAssets) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    GlossaryTerm upsertTerm(GlossaryTerm item) {
        synchronized (_lock) {
            _glossaryTerms[scopedKey(item.tenantId, "term", item.termId)] = item;
            return item;
        }
    }

    GlossaryTerm[] listTerms(string tenantId) {
        GlossaryTerm[] values;
        synchronized (_lock) {
            foreach (key, value; _glossaryTerms) if (belongsTo(key, tenantId)) values ~= value;
        }
        return values;
    }

    KPI upsertKPI(KPI item) {
        synchronized (_lock) {
            _kpis[scopedKey(item.tenantId, "kpi", item.kpiId)] = item;
            return item;
        }
    }

    KPI[] listKPIs(string tenantId) {
        KPI[] values;
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

    AuditEvent addAuditEvent(AuditEvent item) {
        synchronized (_lock) {
            _auditEvents[item.tenantId] ~= item;
            return item;
        }
    }

    AuditEvent[] listAuditEvents(string tenantId) {
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
