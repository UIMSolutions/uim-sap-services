/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.service.helpers.helper;

import std.process : environment;
import std.uuid : randomUUID;
import std.conv : to;
import std.datetime : Clock;
import uim.sap.service;

mixin(ShowModule!());

@safe:

string createId() {
  return randomUUID().toString();
}

string envOr(string key, string fallback) {
  auto value = environment.get(key, "");
  return value.length > 0 ? value : fallback;
}

ushort readPort(string value, ushort fallback) {
  try {
    auto parsed = to!ushort(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}

bool readBool(string value, bool fallback) {
  auto normalized = value.dup;
  foreach (index, c; normalized) {
    if (c >= 'A' && c <= 'Z') {
      normalized[index] = cast(char)(c + 32);
    }
  }

  if (normalized == "1" || normalized == "true" || normalized == "yes" || normalized == "y") {
    return true;
  }
  if (normalized == "0" || normalized == "false" || normalized == "no" || normalized == "n") {
    return false;
  }
  return fallback;
}

string[] stringArrayFromJson(Json values) {
  string[] result;
  if (values.type != Json.Type.array) {
    return result;
  }

  foreach (item; values.get!(Json[])) {
    if (item.isString) {
      result ~= item.get!string;
    }
  }
  return result;
}

int readInt(string value, int fallback) {
  try {
    auto parsed = to!int(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}

double readDouble(string value, double fallback) {
  try {
    auto parsed = to!double(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}

size_t readSize(string value, size_t fallback) {
  try {
    auto parsed = to!size_t(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}


/// Cosine-similarity between two attribute maps (simple text-match version).
/// Returns a value between 0.0 and 1.0.
double attributeSimilarity(const string[string] a, const string[string] b) {
    if (a.length == 0 || b.length == 0)
        return 0.0;
    size_t matches = 0;
    size_t total = 0;
    foreach (k, v; a) {
        if (auto bv = k in b) {
            total++;
            if (*bv == v)
                matches++;
        } else {
            total++;
        }
    }
    foreach (k, _; b) {
        if (k !in a)
            total++;
    }
    if (total == 0)
        return 0.0;
    return cast(double) matches / cast(double) total;
}

/// Simple text-relevance score (case-insensitive substring match).
double textRelevance(string text, string query) {
    import std.uni : toLower;
    if (query.length == 0)
        return 0.0;
    auto lt = text.toLower;
    auto lq = query.toLower;
    if (lt == lq)
        return 1.0;
    import std.algorithm : canFind;
    if (lt.canFind(lq))
        return 0.6;
    return 0.0;
}

string nowTimestamp() {
    return "2026-03-10T00:00:00Z";
}