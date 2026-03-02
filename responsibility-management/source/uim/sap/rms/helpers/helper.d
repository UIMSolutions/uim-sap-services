module uim.sap.rms.helpers.helper;

import uim.sap.rms;

mixin(ShowModule!());

@safe:


enum RuleMode {
    condition,
    externalApi
}

string modeToString(RuleMode mode) {
    return mode == RuleMode.externalApi ? "external_api" : "condition";
}

RuleMode modeFromString(string value) {
    return toLower(value) == "external_api" ? RuleMode.externalApi : RuleMode.condition;
}

string nowIso() {
    return Clock.currTime().toISOExtString();
}
