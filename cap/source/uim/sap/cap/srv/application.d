/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.srv.application;

import uim.sap.cap.cds.model;
import uim.sap.cap.events.types;
import uim.sap.cap.events.context;
import uim.sap.cap.events.handler;
import uim.sap.cap.db.database;
import uim.sap.cap.srv.crud;
import uim.sap.cap.ql.select;
import uim.sap.cap.ql.insert;
import uim.sap.cap.ql.update;
import uim.sap.cap.ql.delete_;
import uim.sap.service;

/// Core CAP application service with event-driven handler pipeline.
/// Subclass this and override setup() to register custom before/on/after handlers.
///
/// Example:
/// ---
/// class CatalogService : ApplicationService {
///     override void setup() {
///         this.before(CrudEvent.CREATE, "Books", delegate Json(CdsEventContext ctx) {
///             if (ctx.data["title"].get!string.length == 0)
///                 throw new SAPValidationException("Title is required");
///             return ctx.data;
///         });
///     }
/// }
/// ---
class ApplicationService : SAPService {
    private CdsModel _model;
    private DatabaseService _db;
    private CrudHandler _crud;
    private HandlerRegistration[] _handlers;
    private ActionRegistration[] _actions;

    this(CdsModel model, DatabaseService db) {
        _model = model;
        _db = db;
        _crud = new CrudHandler(db, model);
    }

    /// Access the CDS model.
    CdsModel model() { return _model; }

    /// Access the database service.
    DatabaseService db() { return _db; }

    /// Override this method to register custom event handlers and actions.
    void setup() {
        // Subclasses override to register handlers
    }

    // --- Handler Registration (CAP-style before/on/after) ---

    /// Register a BEFORE handler for a specific event and entity.
    void before(CrudEvent event, string entity, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.BEFORE, event, entity, handler);
    }

    /// Register an ON handler (replaces default CRUD for this event/entity).
    void on(CrudEvent event, string entity, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.ON, event, entity, handler);
    }

    /// Register an AFTER handler for a specific event and entity.
    void after(CrudEvent event, string entity, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.AFTER, event, entity, handler);
    }

    /// Register an ERROR handler for a specific event and entity.
    void onError(CrudEvent event, string entity, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.ERROR, event, entity, handler);
    }

    /// Register a BEFORE handler for all entities.
    void before(CrudEvent event, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.BEFORE, event, "*", handler);
    }

    /// Register an AFTER handler for all entities.
    void after(CrudEvent event, EventHandler handler) {
        _handlers ~= HandlerRegistration(Phase.AFTER, event, "*", handler);
    }

    /// Register a custom (unbound) action.
    void action_(string actionName, EventHandler handler) {
        _actions ~= ActionRegistration(actionName, handler);
    }

    /// Register a custom action bound to an entity.
    void boundAction(string actionName, string entity, EventHandler handler) {
        _actions ~= ActionRegistration(actionName, handler, entity);
    }

    // --- Query Execution ---

    /// Execute a CQL SELECT query through the handler pipeline.
    Json run(CqlSelect query) {
        return _db.run(query);
    }

    /// Execute a CQL INSERT query.
    Json run(CqlInsert query) {
        return _db.run(query);
    }

    /// Execute a CQL UPDATE query.
    Json run(CqlUpdate query) {
        return _db.run(query);
    }

    /// Execute a CQL DELETE query.
    Json run(CqlDelete query) {
        return _db.run(query);
    }

    // --- Event Dispatching (handler pipeline) ---

    /// Dispatch a CRUD event through the before → on → after pipeline.
    Json dispatch(CrudEvent event, string entity, Json data,
                  string[string] params = null, string user = "", string tenant = "") {
        auto ctx = new CdsEventContext(event, entity, data);
        if (params !is null)
            ctx.params = params;
        ctx.user = user;
        ctx.tenant = tenant;

        try {
            // Phase 1: BEFORE handlers
            foreach (h; getHandlers(Phase.BEFORE, event, entity))
                ctx.data = h(ctx);

            // Phase 2: ON handlers (or default CRUD)
            auto onHandlers = getHandlers(Phase.ON, event, entity);
            if (onHandlers.length > 0) {
                foreach (h; onHandlers)
                    ctx.result = h(ctx);
            } else {
                // Default: delegate to CrudHandler
                ctx.result = _crud.handle(ctx);
            }

            // Phase 3: AFTER handlers
            foreach (h; getHandlers(Phase.AFTER, event, entity))
                ctx.result = h(ctx);

            return ctx.result;

        } catch (Exception e) {
            // Phase ERROR: error handlers
            auto errorHandlers = getHandlers(Phase.ERROR, event, entity);
            if (errorHandlers.length > 0) {
                ctx.params["error"] = e.msg;
                foreach (h; errorHandlers) {
                    try {
                        ctx.result = h(ctx);
                    } catch (Exception) {
                        // Error handler itself failed, re-throw original
                    }
                }
                return ctx.result;
            }
            throw e;
        }
    }

    /// Dispatch a custom action.
    Json dispatchAction(string actionName, Json data,
                        string[string] params = null, string user = "", string tenant = "") {
        foreach (action; _actions) {
            if (action.actionName == actionName) {
                auto ctx = new CdsEventContext();
                ctx.actionName = actionName;
                ctx.data = data;
                if (params !is null)
                    ctx.params = params;
                ctx.user = user;
                ctx.tenant = tenant;
                return action.handler(ctx);
            }
        }
        throw new SAPValidationException("Unknown action: " ~ actionName);
    }

    /// Retrieve registered handlers matching a phase, event, and entity.
    private EventHandler[] getHandlers(Phase phase, CrudEvent event, string entity) {
        EventHandler[] result;
        foreach (h; _handlers) {
            if (h.phase == phase && h.event == event
                && (h.entity == entity || h.entity == "*")) {
                result ~= h.handler;
            }
        }
        return result;
    }
}
