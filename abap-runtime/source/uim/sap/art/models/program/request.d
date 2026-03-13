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
struct ARTProgramRequest {
  string program;
  string user;
  string client;
  string language = "EN";
  Json parameters = Json.emptyObject;
  string correlationId;

  static ARTProgramRequest fromJson(Json payload) {
    ARTProgramRequest request;

    if ("program" in payload && payload["program"].isString) {
      request.program = payload["program"].get!string;
    }

    if ("user" in payload && payload["user"].isString) {
      request.user = payload["user"].get!string;
    }

    if ("client" in payload && payload["client"].isString) {
      request.client = payload["client"].get!string;
    }

    if ("language" in payload && payload["language"].isString) {
      request.language = payload["language"].get!string;
    }

    if ("parameters" in payload) {
      request.parameters = payload["parameters"];
    }

    if ("correlationId" in payload && payload["correlationId"].isString) {
      request.correlationId = payload["correlationId"].get!string;
    }

    return request;
  }

  Json toJson() const {
    Json payload = Json.emptyObject;
    payload["program"] = program;
    payload["user"] = user;
    payload["client"] = client;
    payload["language"] = language;
    payload["parameters"] = parameters;
    payload["correlationId"] = correlationId;
    return payload;
  }
}
