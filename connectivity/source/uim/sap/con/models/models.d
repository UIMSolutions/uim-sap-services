/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.con.models.models;

import std.algorithm.searching : canFind;
import std.datetime : Clock, SysTime;
import std.string : toLower;

import vibe.data.json : Json;

enum string[] CON_SUPPORTED_PROTOCOLS = ["http", "rfc", "tcp", "jdbc", "odbc"];





