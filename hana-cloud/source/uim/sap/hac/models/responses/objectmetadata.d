/**
 * Response models for HANA operations
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.hcd.models.responses.response2;

import vibe.data.json;
import std.datetime : SysTime;


/**
 * Metadata about a database object
 */
struct ObjectMetadata {
    string schema;
    string name;
    string type; // TABLE, VIEW, PROCEDURE, etc.
    string owner;
    SysTime createdAt;
    SysTime modifiedAt;
    long rowCount;
    long sizeBytes;
    string description;
}
