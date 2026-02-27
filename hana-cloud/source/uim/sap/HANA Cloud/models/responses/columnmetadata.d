/**
 * Response models for HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.hcd.models.responses.response3;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * Column metadata
 */
struct ColumnMetadata {
    string name;
    string dataType;
    int length;
    int precision;
    int scale;
    bool nullable;
    bool isPrimaryKey;
    bool isForeignKey;
    string defaultValue;
    string comment;
}
