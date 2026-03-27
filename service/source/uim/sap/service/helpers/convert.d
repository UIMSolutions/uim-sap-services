module uim.sap.service.helpers.convert;
import uim.sap.service;

mixin(ShowModule!());

@safe:
private Json toJsonArray(string[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}

Json toJsonArray(SAPObject[] metrics) {
  return metrics.map!(m => m.toJson()).array.toJson;
}

private Json toJsonArray(T)(T[] values) {
  return values.map!(v => v.toJson()).array.toJson;
}
