module uim.sap.service.helpers.read;

import uim.sap.service;

mixin(ShowModule!());

@safe:

SysTime readTime(Json item, string key) {
  return !(key in item) || !item[key].isString
    ? SysTime.fromISOExtString("1970-01-01T00:00:00Z") 
    : parseTime(item[key].get!string);
}
