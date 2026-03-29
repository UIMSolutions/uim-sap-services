module uim.sap.art.models.program.result;

import uim.sap.art;

mixin(ShowModule!());

@safe:

class ARTProgramResult : SAPEntity {
  mixin(SAPEntityTemplate!ARTProgramResult);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    success = initData.getBool("success", false);
    message = initData.getString("message", "");
    statusCode = initData.getInt("statusCode", 200);
    data = initData.getObject("data", Json.emptyObject);
    program = initData.getString("program", "");
    timestamp = initData.getTime("timestamp", Clock.currTime());
    if ("correlationId" in initData && initData["correlationId"].isString) {
      correlationId = UUID(initData["correlationId"].get!string);
    }

    return true;
  }

  bool success;
  string message;
  int statusCode;
  Json data;
  string program;
  SysTime timestamp;
  UUID correlationId;

  override Json toJson() {
    return super.toJson
      .set("success", success)
      .set("message", message)
      .set("statusCode", statusCode)
      .set("data", data)
      .set("program", program)
      .set("timestamp", timestamp.toISOExtString())
      .set("correlationId", correlationId);
  }
}
