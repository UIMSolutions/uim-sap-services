module uim.sap.art.models.program.request;

struct ARTProgramRequest {
  string program;
  string user;
  string client;
  string language = "EN";
  Json parameters = Json.emptyObject;
  string correlationId;

  static ARTProgramRequest fromJson(Json payload) {
    ARTProgramRequest request;

    if ("program" in payload && payload["program"].type == Json.Type.string) {
      request.program = payload["program"].get!string;
    }

    if ("user" in payload && payload["user"].type == Json.Type.string) {
      request.user = payload["user"].get!string;
    }

    if ("client" in payload && payload["client"].type == Json.Type.string) {
      request.client = payload["client"].get!string;
    }

    if ("language" in payload && payload["language"].type == Json.Type.string) {
      request.language = payload["language"].get!string;
    }

    if ("parameters" in payload) {
      request.parameters = payload["parameters"];
    }

    if ("correlationId" in payload && payload["correlationId"].type == Json.Type.string) {
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
