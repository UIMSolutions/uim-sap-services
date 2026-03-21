/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.pre.store;

import uim.sap.pre;

mixin(ShowModule!());
  @safe:
class PREStore : SAPStore {
    private {
        // Keyed by tenantKey(tenantId, resourceId)
        PREItem[string] _items;
        PREUser[string] _users;
        PREInteraction[string] _interactions;
        PREModel[string] _models;
        PREScenario[string] _scenarios;
        PRETrainingJob[string] _trainingJobs;

        import core.sync.mutex : Mutex;
        Mutex _mutex;
    }

    this() {
        _mutex = new Mutex();
    }

    // ──────── Items ────────

    void addItem(UUID tenantId, ref PREItem item) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, item.itemId);
            _items[key] = item;
        }
    }

    PREItem* getItem(UUID tenantId, string itemId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, itemId);
            if (auto p = key in _items)
                return p;
            return null;
        }
    }

    PREItem[] listItems(UUID tenantId) {
        synchronized (_mutex) {
            PREItem[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _items)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    bool removeItem(UUID tenantId, string itemId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, itemId);
            if (key in _items) {
                _items.remove(key);
                return true;
            }
            return false;
        }
    }

    size_t countItems(UUID tenantId) {
        synchronized (_mutex) {
            size_t n;
            auto prefix = tenantId ~ "/";
            foreach (k, _; _items)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    n++;
            return n;
        }
    }

    // ──────── Users ────────

    void addUser(UUID tenantId, ref PREUser user) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, user.userId);
            _users[key] = user;
        }
    }

    PREUser* getUser(UUID tenantId, string userId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, userId);
            if (auto p = key in _users)
                return p;
            return null;
        }
    }

    PREUser[] listUsers(UUID tenantId) {
        synchronized (_mutex) {
            PREUser[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _users)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    bool removeUser(UUID tenantId, string userId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, userId);
            if (key in _users) {
                _users.remove(key);
                return true;
            }
            return false;
        }
    }

    size_t countUsers(UUID tenantId) {
        synchronized (_mutex) {
            size_t n;
            auto prefix = tenantId ~ "/";
            foreach (k, _; _users)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    n++;
            return n;
        }
    }

    // ──────── Interactions ────────

    void addInteraction(UUID tenantId, ref PREInteraction interaction) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, interaction.interactionId);
            _interactions[key] = interaction;
        }
    }

    PREInteraction[] listInteractionsByUser(UUID tenantId, string userId) {
        synchronized (_mutex) {
            PREInteraction[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _interactions)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix && v.userId == userId)
                    result ~= v;
            return result;
        }
    }

    PREInteraction[] listInteractionsByItem(UUID tenantId, string itemId) {
        synchronized (_mutex) {
            PREInteraction[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _interactions)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix && v.itemId == itemId)
                    result ~= v;
            return result;
        }
    }

    PREInteraction[] listInteractions(UUID tenantId) {
        synchronized (_mutex) {
            PREInteraction[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _interactions)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    size_t countInteractionsByUser(UUID tenantId, string userId) {
        synchronized (_mutex) {
            size_t n;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _interactions)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix && v.userId == userId)
                    n++;
            return n;
        }
    }

    // ──────── Models ────────

    void addModel(UUID tenantId, ref PREModel model) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, model.modelId);
            _models[key] = model;
        }
    }

    PREModel* getModel(UUID tenantId, string modelId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, modelId);
            if (auto p = key in _models)
                return p;
            return null;
        }
    }

    PREModel[] listModels(UUID tenantId) {
        synchronized (_mutex) {
            PREModel[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _models)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    bool removeModel(UUID tenantId, string modelId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, modelId);
            if (key in _models) {
                _models.remove(key);
                return true;
            }
            return false;
        }
    }

    size_t countModels(UUID tenantId) {
        synchronized (_mutex) {
            size_t n;
            auto prefix = tenantId ~ "/";
            foreach (k, _; _models)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    n++;
            return n;
        }
    }

    // ──────── Scenarios ────────

    void addScenario(UUID tenantId, ref PREScenario scenario) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, scenario.scenarioId);
            _scenarios[key] = scenario;
        }
    }

    PREScenario* getScenario(UUID tenantId, string scenarioId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, scenarioId);
            if (auto p = key in _scenarios)
                return p;
            return null;
        }
    }

    PREScenario[] listScenarios(UUID tenantId) {
        synchronized (_mutex) {
            PREScenario[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _scenarios)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix)
                    result ~= v;
            return result;
        }
    }

    bool removeScenario(UUID tenantId, string scenarioId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, scenarioId);
            if (key in _scenarios) {
                _scenarios.remove(key);
                return true;
            }
            return false;
        }
    }

    // ──────── Training Jobs ────────

    void addTrainingJob(UUID tenantId, ref PRETrainingJob job) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, job.jobId);
            _trainingJobs[key] = job;
        }
    }

    PRETrainingJob* getTrainingJob(UUID tenantId, string jobId) {
        synchronized (_mutex) {
            auto key = tenantKey(tenantId, jobId);
            if (auto p = key in _trainingJobs)
                return p;
            return null;
        }
    }

    PRETrainingJob[] listTrainingJobs(UUID tenantId, string modelId) {
        synchronized (_mutex) {
            PRETrainingJob[] result;
            auto prefix = tenantId ~ "/";
            foreach (k, v; _trainingJobs)
                if (k.length >= prefix.length && k[0 .. prefix.length] == prefix && v.modelId == modelId)
                    result ~= v;
            return result;
        }
    }
}
