/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.db.database;

import uim.sap.cap.cds.model;
import uim.sap.cap.ql.select;
import uim.sap.cap.ql.insert;
import uim.sap.cap.ql.update;
import uim.sap.cap.ql.delete_;
import uim.sap.service;

/// Abstract database service interface for CAP persistence.
/// Implementations handle actual data storage (in-memory, SQL, HANA, etc.).
interface DatabaseService {
    /// Deploy the CDS model (create tables/collections).
    void deploy(CdsModel model);

    /// Execute a SELECT query. Returns a JSON array of matching rows,
    /// or a JSON object with "value" array and optional "@odata.count".
    Json run(CqlSelect query);

    /// Execute an INSERT query. Returns the inserted entry/entries as JSON.
    Json run(CqlInsert query);

    /// Execute an UPDATE query. Returns the number of affected rows.
    Json run(CqlUpdate query);

    /// Execute a DELETE query. Returns the number of deleted rows.
    Json run(CqlDelete query);
}
