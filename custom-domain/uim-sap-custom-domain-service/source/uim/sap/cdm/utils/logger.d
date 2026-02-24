module utils.logger;

import std.stdio;
import vibe.vibe;

void logInfo(string message) {
    writeln("[INFO] ", message);
}

void logWarning(string message) {
    writeln("[WARNING] ", message);
}

void logError(string message) {
    writeln("[ERROR] ", message);
}

void logRequest(HttpRequest req) {
    logInfo("Received request: " ~ req.method ~ " " ~ req.url);
}

void logResponse(HttpResponse res) {
    logInfo("Sending response: " ~ res.statusCode.to!string ~ " " ~ res.reasonPhrase);
}

void logException(Exception e) {
    logError("Exception occurred: " ~ e.msg);
}