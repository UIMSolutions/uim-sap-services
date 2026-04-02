/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.cap.srv.crud;

import uim.sap.cap.cds.model;
import uim.sap.cap.events.types;
import uim.sap.cap.events.context;
import uim.sap.cap.ql.select;
import uim.sap.cap.ql.insert;
import uim.sap.cap.ql.update;
import uim.sap.cap.ql.delete_;
import uim.sap.cap.ql.filter;
import uim.sap.cap.db.database;
import uim.sap.service;

/// Default CRUD handler that delegates to the DatabaseService.
/// Used as the ON handler when no custom ON handler is registered.
class CrudHandler {
    private DatabaseService _db;
    private CdsModel _model;

    this(DatabaseService db, CdsModel model) {
        _db = db;
        _model = model;
    }

    /// Execute default CRUD based on the event type.
    Json handle(CdsEventContext ctx) {
        final switch (ctx.event) {
            case CrudEvent.CREATE: return handleCreate(ctx);
            case CrudEvent.READ:   return handleRead(ctx);
            case CrudEvent.UPDATE: return handleUpdate(ctx);
            case CrudEvent.DELETE: return handleDelete(ctx);
        }
    }

    private Json handleCreate(CdsEventContext ctx) {
        auto query = new CqlInsert(ctx.entity);
        // Set managed fields
        auto data = ctx.data;
        auto now = Clock.currTime().toISOExtString();
        auto entDef = _model !is null ? _model.getEntity(ctx.entity) : null;

        if (entDef !is null && entDef.hasField("createdAt"))
            data["createdAt"] = Json(now);
        if (entDef !is null && entDef.hasField("createdBy"))
            data["createdBy"] = Json(ctx.user.length > 0 ? ctx.user : "anonymous");
        if (entDef !is null && entDef.hasField("modifiedAt"))
            data["modifiedAt"] = Json(now);
        if (entDef !is null && entDef.hasField("modifiedBy"))
            data["modifiedBy"] = Json(ctx.user.length > 0 ? ctx.user : "anonymous");

        query.entry(data);
        return _db.run(query);
    }

    private Json handleRead(CdsEventContext ctx) {
        auto query = new CqlSelect(ctx.entity);

        // Check for single entity read by ID
        auto entityId = ctx.param("id");
        if (entityId.length > 0)
            query.byId(entityId);

        // Apply $top
        auto topParam = ctx.param("$top");
        if (topParam.length > 0) {
            try {
                import std.conv : to;
                query.limit_(topParam.to!int);
            } catch (Exception) {}
        }

        // Apply $skip
        auto skipParam = ctx.param("$skip");
        if (skipParam.length > 0) {
            try {
                import std.conv : to;
                query.offset_(skipParam.to!int);
            } catch (Exception) {}
        }

        // Apply $select
        auto selectParam = ctx.param("$select");
        if (selectParam.length > 0) {
            import std.string : split;
            foreach (col; selectParam.split(",")) {
                import std.string : strip;
                auto trimmed = col.strip();
                if (trimmed.length > 0)
                    query.col(trimmed);
            }
        }

        // Apply $orderby
        auto orderParam = ctx.param("$orderby");
        if (orderParam.length > 0) {
            import std.string : split, strip, toLower;
            auto parts = orderParam.split(",");
            foreach (part; parts) {
                auto trimmed = part.strip();
                auto segments = trimmed.split(" ");
                if (segments.length > 0) {
                    auto field = segments[0].strip();
                    auto desc = segments.length > 1 && toLower(segments[1].strip()) == "desc";
                    query.orderBy(field, desc);
                }
            }
        }

        // Apply $count
        if (ctx.param("$count") == "true")
            query.withCount();

        return _db.run(query);
    }

    private Json handleUpdate(CdsEventContext ctx) {
        auto entityId = ctx.param("id");
        if (entityId.length == 0)
            throw new SAPValidationException("Entity ID required for UPDATE");

        auto query = new CqlUpdate(ctx.entity);
        query.data_(ctx.data);
        query.byId(entityId);

        // Set managed fields
        auto entDef = _model !is null ? _model.getEntity(ctx.entity) : null;
        auto now = Clock.currTime().toISOExtString();
        if (entDef !is null && entDef.hasField("modifiedAt"))
            query.set("modifiedAt", now);
        if (entDef !is null && entDef.hasField("modifiedBy"))
            query.set("modifiedBy", ctx.user.length > 0 ? ctx.user : "anonymous");

        return _db.run(query);
    }

    private Json handleDelete(CdsEventContext ctx) {
        auto entityId = ctx.param("id");
        if (entityId.length == 0)
            throw new SAPValidationException("Entity ID required for DELETE");

        auto query = new CqlDelete(ctx.entity);
        query.byId(entityId);
        return _db.run(query);
    }
}
