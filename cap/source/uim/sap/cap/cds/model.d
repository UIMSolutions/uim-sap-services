/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.cds.model;

import uim.sap.cap.cds.entity;

/// A CDS Model groups entity definitions under a namespace.
/// Corresponds to a .cds schema file in SAP CAP.
class CdsModel {
    string namespace;
    CdsEntityDef[string] entities;

    this(string namespace) {
        this.namespace = namespace;
    }

    /// Register an entity definition in this model.
    CdsModel entity(CdsEntityDef ent) {
        entities[ent.name] = ent;
        return this;
    }

    /// Look up an entity by name.
    CdsEntityDef getEntity(string name) {
        if (auto p = name in entities)
            return *p;
        return null;
    }

    /// Check whether an entity exists in the model.
    bool hasEntity(string name) const {
        return (name in entities) !is null;
    }

    /// Return all entity names.
    string[] entityNames() const {
        string[] names;
        foreach (n; entities.keys)
            names ~= n;
        return names;
    }
}
