module uim.sap.con.models.models;

import std.algorithm.searching : canFind;
import std.datetime : Clock, SysTime;
import std.string : toLower;

import vibe.data.json : Json;

enum string[] CON_SUPPORTED_PROTOCOLS = ["http", "rfc", "tcp", "jdbc", "odbc"];





