/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.events.handler;

import uim.sap.cap.events.types;
import uim.sap.cap.events.context;
import uim.sap.service;

/// Delegate type for event handlers. Receives context, returns modified result.
alias EventHandler = Json delegate(CdsEventContext);

/// Registration record for a single event handler.
struct HandlerRegistration {
    Phase phase;
    CrudEvent event;
    string entity;        /// Entity name ("*" matches all entities)
    EventHandler handler;
    int priority = 0;     /// Lower runs first
}

/// Registration record for a custom action handler.
struct ActionRegistration {
    string actionName;
    EventHandler handler;
    string boundEntity;   /// Empty for unbound actions
}
