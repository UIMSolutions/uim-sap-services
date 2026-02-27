module app;

import std.conv : to;
import std.process : environment;
import std.stdio : writeln;
import std.string : toLower;

import uim.sap.jobs;

void main() {
    JobSchedulingConfig config;
    config.host = envOr("JOBS_HOST", "0.0.0.0");
    config.port = readPort(envOr("JOBS_PORT", "8101"), 8101);
    config.basePath = envOr("JOBS_BASE_PATH", "/api/job-scheduling");
    config.serviceName = envOr("JOBS_SERVICE_NAME", "uim-sap-job-scheduling");
    config.serviceVersion = envOr("JOBS_SERVICE_VERSION", UIM_JOB_SCHEDULING_VERSION);
    config.schedulerTickMs = readInt(envOr("JOBS_SCHEDULER_TICK_MS", "1000"), 1000);
    config.alertEndpoint = envOr("JOBS_ALERT_ENDPOINT", "");
    config.alertApiKey = envOr("JOBS_ALERT_API_KEY", "");
    config.cloudAlmEndpoint = envOr("JOBS_CLOUD_ALM_ENDPOINT", "");
    config.cloudAlmApiKey = envOr("JOBS_CLOUD_ALM_API_KEY", "");
    config.outboundOauthToken = envOr("JOBS_OUTBOUND_OAUTH_TOKEN", "");

    auto token = envOr("JOBS_AUTH_TOKEN", "");
    if (token.length > 0) {
        config.requireAuthToken = true;
        config.authToken = token;
    }

    config.customHeaders["X-Service"] = config.serviceName;
    config.customHeaders["X-Version"] = config.serviceVersion;

    auto service = new JobSchedulingService(config);
    auto server = new JobSchedulingServer(service);

    writeln("Starting Job Scheduling service on ", config.host, ":", config.port);
    writeln("Base path: ", config.basePath);
    server.run();
}

private string envOr(string key, string fallback) {
    auto value = environment.get(key, "");
    return value.length > 0 ? value : fallback;
}

private ushort readPort(string value, ushort fallback) {
    try {
        auto parsed = to!ushort(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}

private int readInt(string value, int fallback) {
    try {
        auto parsed = to!int(value);
        return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
        return fallback;
    }
}

private bool readBool(string value, bool fallback) {
    auto normalized = toLower(value);
    if (normalized == "true" || normalized == "1" || normalized == "yes") return true;
    if (normalized == "false" || normalized == "0" || normalized == "no") return false;
    return fallback;
}
