module uim.sap.service.helpers.convert;
import uim.sap.service;

mixin(ShowModule!());

@safe:
private Json toJsonArray(string[] values) const {
  return values.map!(v => v.toJson()).array.toJson;
}

private Json toJsonArray(T)(T[] values) const {
  return values.map!(v => v.toJson()).array.toJson;
}
