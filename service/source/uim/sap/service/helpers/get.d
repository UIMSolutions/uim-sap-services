module uim.sap.service.helpers.get;

import uim.sap.service;

mixin(ShowModule!());

@safe:

// #region getLong
long getLong(Json json, string key, long defaultValue = 0) {
  return key in json && json[key].isInteger
    ? json[key].get!long
    : defaultValue; 
}

long getLong(Json[string] json, string key, long defaultValue = 0) {
  Json value = json.get(key, Json(defaultValue));
  return value.isInteger
    ? value.get!long
    : defaultValue; 
}

long getLong(Json json, long defaultValue = 0) {
  return json.isInteger
    ? json.get!long
    : defaultValue;
}
// #endregion getLong

// #region getSize
size_t getSize(Json json, string key, size_t defaultValue = 0) {
  return key in json && json[key].isInteger
    ? json[key].get!size_t
    : defaultValue;
}

size_t getSize(Json[string] json, string key, size_t defaultValue = 0) {
  Json value = json.get(key, Json(defaultValue));
  return value.isInteger
    ? value.get!size_t
    : defaultValue;
}

size_t getSize(Json json, size_t defaultValue = 0) {
  return json.isInteger
    ? json.get!size_t
    : defaultValue;
}
// #endregion getSize
