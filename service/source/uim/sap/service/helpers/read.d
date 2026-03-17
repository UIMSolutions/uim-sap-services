module uim.sap.service.helpers.read;

import uim.sap.service;

mixin(ShowModule!());

@safe:

SysTime readTime(Json item, string key) {
  return !(key in item) || !item[key].isString
    ? SysTime.fromISOExtString("1970-01-01T00:00:00Z") : parseTime(item[key].get!string);
}

string[] readStringArray(Json data, string key) const {
  string[] values;
  if (!(key in data) || data[key].isNull)
    return values;

  requiredArrayType(data, key);
  
  foreach (item; data[key].toArray) {
    if (!item.isString)
      throw new CMGValidationException(key ~ " must contain strings");

    values ~= item.get!string;
  }
  return values;
}

Json readObject(Json data, string key) const {
  if (!(key in data) || data[key].isNull) {
    return Json.emptyObject;
  }

  requiredObjectType(data, key);
  return data[key];
}
