/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.isa.store;

import core.sync.mutex : Mutex;
import std.datetime : Clock;
import std.uuid : randomUUID;

import vibe.data.json : Json;

import uim.sap.isa.models;

class ISAStore : SAPStore {
    private AutomationConfiguration[string] _configs;
    private SituationInstance[][string] _situationsByTenant;
    private DataContextReport[][string] _reportsByTenant;
    private Mutex _lock;

    this() {
        _lock = new Mutex;
    }

    AutomationConfiguration createConfiguration(AutomationConfiguration config) {
        synchronized (_lock) {
            _configs[config.id] = config;
            return config;
        }
    }

    AutomationConfiguration updateConfiguration(string id, AutomationConfiguration updated) {
        synchronized (_lock) {
            if (auto ptr = id in _configs) {
                *ptr = updated;
                return *ptr;
            }
        }
        return AutomationConfiguration.init;
    }

    bool deleteConfiguration(string id) {
        synchronized (_lock) {
            if (id in _configs) {
                _configs.remove(id);
                return true;
            }
            return false;
        }
    }

    AutomationConfiguration getConfiguration(string id) {
        synchronized (_lock) {
            if (auto ptr = id in _configs) {
                return *ptr;
            }
        }
        return AutomationConfiguration.init;
    }

    AutomationConfiguration[] listConfigurations(string tenantId) {
        AutomationConfiguration[] result;
        synchronized (_lock) {
            foreach (cfg; _configs.byValue) {
                if (cfg.tenantId == tenantId) {
                    result ~= cfg;
                }
            }
        }
        return result;
    }

    SituationInstance createSituation(SituationInstance instance) {
        synchronized (_lock) {
            _situationsByTenant[instance.tenantId] ~= instance;
            return instance;
        }
    }

    SituationInstance[] listSituations(string tenantId) {
        synchronized (_lock) {
            if (auto ptr = tenantId in _situationsByTenant) {
                return (*ptr).dup;
            }
        }
        return [];
    }

    DataContextReport addReport(DataContextReport report) {
        synchronized (_lock) {
            _reportsByTenant[report.tenantId] ~= report;
            return report;
        }
    }

    DataContextReport[] listReports(string tenantId) {
        synchronized (_lock) {
            if (auto ptr = tenantId in _reportsByTenant) {
                return (*ptr).dup;
            }
        }
        return [];
    }

    void seed(string tenantId) {
        synchronized (_lock) {
            if ((tenantId in _situationsByTenant) !is null) {
                return;
            }

            SituationInstance[] defaults;

            SituationInstance delayed;
            delayed.id = randomUUID().toString();
            delayed.tenantId = tenantId;
            delayed.situationType = "delivery_delay";
            delayed.templateId = "tmpl-delivery-delay";
            delayed.entityType = "sales_order";
            delayed.entityId = "SO-10021";
            delayed.status = SituationStatus.autoResolved;
            delayed.resolutionFlow = "auto_reassign_route";
            delayed.dataContext = Json.emptyObject;
            delayed.dataContext["country"] = "DE";
            delayed.dataContext["delay_hours"] = 12;
            delayed.occurredAt = Clock.currTime();
            delayed.resolvedAt = Clock.currTime();
            defaults ~= delayed;

            SituationInstance blockedInvoice;
            blockedInvoice.id = randomUUID().toString();
            blockedInvoice.tenantId = tenantId;
            blockedInvoice.situationType = "blocked_invoice";
            blockedInvoice.templateId = "tmpl-invoice-blocked";
            blockedInvoice.entityType = "invoice";
            blockedInvoice.entityId = "INV-7788";
            blockedInvoice.status = SituationStatus.resolved;
            blockedInvoice.resolutionFlow = "manual_approval";
            blockedInvoice.dataContext = Json.emptyObject;
            blockedInvoice.dataContext["amount"] = 12800;
            blockedInvoice.dataContext["currency"] = "EUR";
            blockedInvoice.occurredAt = Clock.currTime();
            blockedInvoice.resolvedAt = Clock.currTime();
            defaults ~= blockedInvoice;

            SituationInstance latePayment;
            latePayment.id = randomUUID().toString();
            latePayment.tenantId = tenantId;
            latePayment.situationType = "late_payment_risk";
            latePayment.templateId = "tmpl-payment-risk";
            latePayment.entityType = "business_partner";
            latePayment.entityId = "BP-2220";
            latePayment.status = SituationStatus.open;
            latePayment.resolutionFlow = "collections_followup";
            latePayment.dataContext = Json.emptyObject;
            latePayment.dataContext["overdue_days"] = 21;
            latePayment.dataContext["credit_exposure"] = 47000;
            latePayment.occurredAt = Clock.currTime();
            defaults ~= latePayment;

            _situationsByTenant[tenantId] = defaults;

            DataContextReport report;
            report.id = randomUUID().toString();
            report.tenantId = tenantId;
            report.title = "Q4 Situation Data Context Import";
            report.entityType = "sales_order";
            report.situationType = "delivery_delay";
            report.importedFrom = "S/4HANA";
            report.importedAt = Clock.currTime();
            _reportsByTenant[tenantId] ~= report;
        }
    }
}
