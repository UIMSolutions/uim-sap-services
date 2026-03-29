/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.helpers.helper;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

enum string[] ANALYTICS_SUPPORTED_STORY_TYPES = [
    "canvas",
    "responsive",
    "optimized"
];

enum string[] ANALYTICS_SUPPORTED_DASHBOARD_LAYOUTS = [
    "grid",
    "freeform",
    "responsive"
];

enum string[] ANALYTICS_SUPPORTED_CONNECTION_TYPES = [
    "live",
    "import",
    "blend"
];

enum string[] ANALYTICS_SUPPORTED_SOURCE_SYSTEMS = [
    "sap_hana",
    "sap_bw",
    "sap_s4hana",
    "sap_datasphere",
    "odata",
    "csv",
    "database"
];

enum string[] ANALYTICS_SUPPORTED_MODEL_TYPES = [
    "planning",
    "analytic",
    "embedded"
];

enum string[] ANALYTICS_SUPPORTED_PREDICTION_TYPES = [
    "time_series",
    "classification",
    "regression",
    "clustering"
];

enum string[] ANALYTICS_USER_ROLES = [
    "admin",
    "bi_admin",
    "planner",
    "viewer",
    "creator"
];

bool isValidStoryType(string storyType) {
  return ANALYTICS_SUPPORTED_STORY_TYPES.canFind(toLower(storyType));
}

bool isValidDashboardLayout(string layout) {
  return ANALYTICS_SUPPORTED_DASHBOARD_LAYOUTS.canFind(toLower(layout));
}

bool isValidConnectionType(string connType) {
  return ANALYTICS_SUPPORTED_CONNECTION_TYPES.canFind(toLower(connType));
}

bool isValidSourceSystem(string sourceSystem) {
  return ANALYTICS_SUPPORTED_SOURCE_SYSTEMS.canFind(toLower(sourceSystem));
}

bool isValidModelType(string modelType) {
  return ANALYTICS_SUPPORTED_MODEL_TYPES.canFind(toLower(modelType));
}

bool isValidPredictionType(string predictionType) {
  return ANALYTICS_SUPPORTED_PREDICTION_TYPES.canFind(toLower(predictionType));
}

bool isValidUserRole(string role) {
  return ANALYTICS_USER_ROLES.canFind(toLower(role));
}

string generateId(string prefix) {
  return prefix ~ "-" ~ randomUUID().toString();
}
