module uim.sap.isa.models.model;

import uim.sap.isa;

mixin(ShowModule!());

@safe:

enum SituationStatus {
  open,
  resolved,
  autoResolved
}

string situationStatusToString(SituationStatus status) {
  final switch (status) {
  case SituationStatus.open:
    return "open";
  case SituationStatus.resolved:
    return "resolved";
  case SituationStatus.autoResolved:
    return "auto_resolved";
  }
}

SituationStatus situationStatusFromString(string value) {
  switch (value) {
  case "open":
    return SituationStatus.open;
  case "resolved":
    return SituationStatus.resolved;
  case "auto_resolved":
    return SituationStatus.autoResolved;
  default:
    return SituationStatus.open;
  }
}









private string getString(Json payload, string key, string fallback) {
  if (!(key in payload)) {
    return fallback;
  }
  try {
    return payload[key].get!string;
  } catch (Exception) {
    return fallback;
  }
}

private bool getBool(Json payload, string key, bool fallback) {
  if (!(key in payload)) {
    return fallback;
  }
  try {
    return payload[key].get!bool;
  } catch (Exception) {
    return fallback;
  }
}

private int getInt(Json payload, string key, int fallback) {
  if (!(key in payload)) {
    return fallback;
  }
  try {
    return cast(int)payload[key].get!long;
  } catch (Exception) {
    return fallback;
  }
}

private double getDouble(Json payload, string key, double fallback) {
  if (!(key in payload)) {
    return fallback;
  }
  try {
    return payload[key].get!double;
  } catch (Exception) {
    return fallback;
  }
}
