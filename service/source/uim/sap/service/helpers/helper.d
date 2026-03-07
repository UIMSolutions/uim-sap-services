/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.service.helpers.helper;

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
