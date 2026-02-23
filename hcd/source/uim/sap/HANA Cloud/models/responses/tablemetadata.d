/**
 * Response models for SAP HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.hcd.models.responses.response4;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * Table metadata with columns
 */
struct TableMetadata {
    ObjectMetadata metadata;
    ColumnMetadata[] columns;
    string[] primaryKeys;
    string[] indexes;
}
