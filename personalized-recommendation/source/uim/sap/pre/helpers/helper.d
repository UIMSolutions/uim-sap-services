module uim.sap.pre.helpers.helper;

import uim.sap.pre;

mixin(ShowModule!());

@safe:

string generateItemId() {
    return "itm-" ~ randomUUID();
}

string generateUserId() {
    return "usr-" ~ randomUUID();
}

string generateInteractionId() {
    return "int-" ~ randomUUID();
}

string generateModelId() {
    return "mdl-" ~ randomUUID();
}

string generateScenarioId() {
    return "scn-" ~ randomUUID();
}

string generateRecommendationId() {
    return "rec-" ~ randomUUID();
}

string generateTrainingJobId() {
    return "trj-" ~ randomUUID();
}

string generateTenantId() {
    return "tnt-" ~ randomUUID();
}

string tenantKey(string tenantId, string resourceId) {
    return tenantId ~ "/" ~ resourceId;
}

/// Cosine-similarity between two attribute maps (simple text-match version).
/// Returns a value between 0.0 and 1.0.
double attributeSimilarity(const string[string] a, const string[string] b) {
    if (a.length == 0 || b.length == 0)
        return 0.0;
    size_t matches = 0;
    size_t total = 0;
    foreach (k, v; a) {
        if (auto bv = k in b) {
            total++;
            if (*bv == v)
                matches++;
        } else {
            total++;
        }
    }
    foreach (k, _; b) {
        if (k !in a)
            total++;
    }
    if (total == 0)
        return 0.0;
    return cast(double) matches / cast(double) total;
}

/// Simple text-relevance score (case-insensitive substring match).
double textRelevance(string text, string query) {
    import std.uni : toLower;
    if (query.length == 0)
        return 0.0;
    auto lt = text.toLower;
    auto lq = query.toLower;
    if (lt == lq)
        return 1.0;
    import std.algorithm : canFind;
    if (lt.canFind(lq))
        return 0.6;
    return 0.0;
}

string nowTimestamp() {
    return "2026-03-10T00:00:00Z";
}
