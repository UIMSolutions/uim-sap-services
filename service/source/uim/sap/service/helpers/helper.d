module uim.sap.service.helpers.helper;

import uim.sap.service;

mixin(ShowModule!());

@safe:

string createId() {
    return randomUUID().toString();
}


private string envOr(string key, string fallback) {
  auto value = environment.get(key, "");
  return value.length > 0 ? value : fallback;
}

private ushort readPort(string value, ushort fallback) {
  try {
    auto parsed = to!ushort(value);
    return parsed > 0 ? parsed : fallback;
  } catch (Exception) {
    return fallback;
  }
}

private bool readBool(string value, bool fallback) {
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
