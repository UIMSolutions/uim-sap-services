module uim.sap.art.models.program.result;

import uim.sap.art;

mixin(ShowModule!());

@safe:


struct ARTProgramResult {
  bool success;
  string message;
  int statusCode = 200;
  Json data = Json.emptyObject;
  string program;
  SysTime timestamp;
  string correlationId;

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["success"] = success;
    payload["message"] = message;
    payload["statusCode"] = statusCode;
    payload["data"] = data;
    payload["program"] = program;
    payload["timestamp"] = timestamp.toISOExtString();
    payload["correlationId"] = correlationId;
    return payload;
  }
}
