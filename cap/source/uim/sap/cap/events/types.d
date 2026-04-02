/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.events.types;

/// CRUD event types, mirroring SAP CAP event names.
enum CrudEvent {
    CREATE,
    READ,
    UPDATE,
    DELETE
}

/// Handler execution phase in the event pipeline.
enum Phase {
    BEFORE,     /// Runs before the main handler (validation, enrichment)
    ON,         /// The main handler (replaces default CRUD if set)
    AFTER,      /// Runs after the main handler (post-processing)
    ERROR       /// Runs on error (error handling, logging)
}
