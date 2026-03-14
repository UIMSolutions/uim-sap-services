module config;

import std.conv : to;
import std.array : array;
import std.process : environment;

struct AppConfig {
    ushort port;
    string bindAddress;
    string serviceName;
    string[] supportedLanguages;
}

private string envOrDefault(string key, string fallback) {
    auto value = environment.get(key, "");
    return value.length ? value : fallback;
}

private string[] parseCsv(string csv, string[] fallback) {
    import std.array : split;
    import std.algorithm : filter, map;
    import std.string : strip;

    if (!csv.length) return fallback;
    auto values = csv.split(",")
        .map!(v => v.strip)
        .filter!(v => v.length > 0)
        .array;
    return values.length ? values : fallback;
}

AppConfig loadConfig() {
    return AppConfig(
        cast(ushort) envOrDefault("PORT", "8080").to!int,
        envOrDefault("BIND_ADDRESS", "0.0.0.0"),
        envOrDefault("SERVICE_NAME", "translation-hub"),
        parseCsv(
            envOrDefault("SUPPORTED_LANGUAGES", "en,de,fr,es,it,pt,ja,ko,zh,ar,ru"),
            ["en", "de"]
        )
    );
}
