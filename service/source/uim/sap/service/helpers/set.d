module uim.sap.service.helpers.set;

import uim.sap.service;

mixin(ShowModule!());

@safe:

Json set(Json json, string key, Json value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, string value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, int value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, long value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, double value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, float value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, bool value) {
  json[key] = value;
  return json;
}

Json set(Json json, string key, UUID value) {
  json[key] = value.toString();
  return json;
}

Json set(T)(Json json, string key, T[] values) {
  return json.set(key, values.map!(v => v.toJson).array.toJson);
}

