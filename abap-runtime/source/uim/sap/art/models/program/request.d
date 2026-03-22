module uim.sap.art.models.program.request;

import uim.sap.art;

mixin(ShowModule!());

@safe:

/**
  * Data structure representing a request to execute an ABAP program in the ART runtime.
  * @since 1.0.0
  * @author Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
  *
  * @property program The name of the ABAP program to execute.
  * @property user The user on whose behalf the program should be executed.
  * @property client The SAP client to use for execution.
  * @property language The logon language to use for execution (default: "EN").
  * @property parameters A JSON object containing any parameters to pass to the program.
  * @property correlationId An optional correlation ID for tracing the request across systems.
  */
class ARTProgramRequest : SAPObject {
  mixin(SAPObjectTemplate!ARTProgramRequest);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("program" in initData && initData["program"].isString) {
      program = initData["program"].get!string;
    }

    if ("user" in initData && initData["user"].isString) {
      user = initData["user"].get!string;
    }

    if ("client" in initData && initData["client"].isString) {
      client = initData["client"].get!string;
    }

    language = initData.getString("language", "EN");

    parameters = initData.getObject("parameters", Json.emptyObject);

    if ("correlationId" in initData && initData["correlationId"].isString) {
      correlationId = UUID(initData["correlationId"].get!string);
    }

    return true;
  }

  string program;
  string user;
  string client;
  string language = "EN";
  Json parameters = Json.emptyObject;
  UUID correlationId;

  static ARTProgramRequest opCall(Json payload) {
    ARTProgramRequest request = new ARTProgramRequest(payload);
    return request;
  }

  override Json toJson() {
    Json info = super.toJson
      .set("program", program)
      .set("user", user)
      .set("client", client)
      .set("language", language)
      .set("parameters", parameters)
      .set("correlationId", correlationId);
  }
}
