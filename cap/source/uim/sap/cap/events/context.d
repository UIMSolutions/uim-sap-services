/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.events.context;

import uim.sap.cap.events.types;
import uim.sap.service;

/// Context object passed to event handlers during the before/on/after pipeline.
/// Carries the request data, query parameters, and accumulated result.
class CdsEventContext {
    /// The CRUD event type.
    CrudEvent event;

    /// The entity name being operated on.
    string entity;

    /// Request data (body payload for CREATE/UPDATE).
    Json data;

    /// Query representation (for READ operations).
    Json query;

    /// Accumulated result (set by ON handler, modifiable by AFTER handlers).
    Json result;

    /// Authenticated user identifier.
    string user;

    /// Tenant identifier for multi-tenancy.
    string tenant;

    /// Additional request parameters (URL path segments, query params).
    string[string] params;

    /// Custom action name (for bound/unbound actions).
    string actionName;

    this() {
        data = Json.emptyObject;
        query = Json.emptyObject;
        result = Json.emptyObject;
    }

    this(CrudEvent event, string entity, Json data) {
        this.event = event;
        this.entity = entity;
        this.data = data;
        this.query = Json.emptyObject;
        this.result = Json.emptyObject;
    }

    /// Get a parameter value with a fallback default.
    string param(string key, string defaultValue = "") {
        if (auto p = key in params)
            return *p;
        return defaultValue;
    }
}
