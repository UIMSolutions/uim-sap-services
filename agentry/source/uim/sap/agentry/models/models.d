module uim.sap.agentry.models;

import std.datetime : Clock, SysTime;
import std.string : toLower;
import std.uuid : randomUUID;

import vibe.data.json : Json;

struct AgentryMobileApp {
  string tenantId;
  string appId;
  string name;
  string backendSystem;
  string ownerTeam;
  string lifecycle = "development";
  SysTime createdAt;
  SysTime updatedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["name"] = name;
    result["backend_system"] = backendSystem;
    result["owner_team"] = ownerTeam;
    result["lifecycle"] = lifecycle;
    result["created_at"] = createdAt.toISOExtString();
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

struct AgentryAppVersion {
  string tenantId;
  string appId;
  string versionId;
  string versionLabel;
  string changeLog;
  string buildStatus = "built";
  SysTime createdAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["version_id"] = versionId;
    result["version_label"] = versionLabel;
    result["change_log"] = changeLog;
    result["build_status"] = buildStatus;
    result["created_at"] = createdAt.toISOExtString();
    return result;
  }
}

struct AgentryTestRun {
  string tenantId;
  string appId;
  string testRunId;
  string versionId;
  string environment;
  string resultStatus;
  long passedCases;
  long failedCases;
  SysTime executedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["app_id"] = appId;
    result["test_run_id"] = testRunId;
    result["version_id"] = versionId;
    result["environment"] = environment;
    result["result_status"] = resultStatus;
    result["passed_cases"] = passedCases;
    result["failed_cases"] = failedCases;
    result["executed_at"] = executedAt.toISOExtString();
    return result;
  }
}

struct AgentryRuntimeInstance {
  string tenantId;
  string instanceId;
  string appId;
  string targetEnvironment;
  string deployedVersionId;
  string status = "running";
  SysTime updatedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["instance_id"] = instanceId;
    result["app_id"] = appId;
    result["target_environment"] = targetEnvironment;
    result["deployed_version_id"] = deployedVersionId;
    result["status"] = status;
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

struct AgentryDevice {
  string tenantId;
  string deviceId;
  string appId;
  string userId;
  string platform;
  string appVersionId;
  SysTime lastSyncAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["device_id"] = deviceId;
    result["app_id"] = appId;
    result["user_id"] = userId;
    result["platform"] = platform;
    result["app_version_id"] = appVersionId;
    result["last_sync_at"] = lastSyncAt.toISOExtString();
    return result;
  }
}

struct AgentryBackendSystem {
  string tenantId;
  string backendId;
  string systemType;
  string endpoint;
  string authMode;
  bool enabled = true;
  SysTime updatedAt;

  Json toJson() const {
    Json result = Json.emptyObject;
    result["tenant_id"] = tenantId;
    result["backend_id"] = backendId;
    result["system_type"] = systemType;
    result["endpoint"] = endpoint;
    result["auth_mode"] = authMode;
    result["enabled"] = enabled;
    result["updated_at"] = updatedAt.toISOExtString();
    return result;
  }
}

AgentryMobileApp appFromJson(string tenantId, Json request, string defaultBackend) {
  AgentryMobileApp app;
  app.tenantId = tenantId;
  app.appId = randomUUID().toString();
  app.backendSystem = defaultBackend;
  app.createdAt = Clock.currTime();
  app.updatedAt = app.createdAt;

  if ("app_id" in request && request["app_id"].isString) {
    app.appId = request["app_id"].get!string;
  }
  if ("name" in request && request["name"].isString) {
    app.name = request["name"].get!string;
  }
  if ("backend_system" in request && request["backend_system"].isString) {
    app.backendSystem = request["backend_system"].get!string;
  }
  if ("owner_team" in request && request["owner_team"].isString) {
    app.ownerTeam = request["owner_team"].get!string;
  }
  if ("lifecycle" in request && request["lifecycle"].isString) {
    app.lifecycle = toLower(request["lifecycle"].get!string);
  }

  return app;
}

AgentryAppVersion versionFromJson(string tenantId, string appId, Json request) {
  AgentryAppVersion appVersion;
  appVersion.tenantId = tenantId;
  appVersion.appId = appId;
  appVersion.versionId = randomUUID().toString();
  appVersion.versionLabel = "1.0.0";
  appVersion.createdAt = Clock.currTime();

  if ("version_id" in request && request["version_id"].isString) {
    appVersion.versionId = request["version_id"].get!string;
  }
  if ("version_label" in request && request["version_label"].isString) {
    appVersion.versionLabel = request["version_label"].get!string;
  }
  if ("change_log" in request && request["change_log"].isString) {
    appVersion.changeLog = request["change_log"].get!string;
  }
  if ("build_status" in request && request["build_status"].isString) {
    appVersion.buildStatus = toLower(request["build_status"].get!string);
  }

  return appVersion;
}

AgentryTestRun testRunFromJson(string tenantId, string appId, Json request) {
  AgentryTestRun testRun;
  testRun.tenantId = tenantId;
  testRun.appId = appId;
  testRun.testRunId = randomUUID().toString();
  testRun.environment = "qa";
  testRun.resultStatus = "passed";
  testRun.executedAt = Clock.currTime();

  if ("test_run_id" in request && request["test_run_id"].isString) {
    testRun.testRunId = request["test_run_id"].get!string;
  }
  if ("version_id" in request && request["version_id"].isString) {
    testRun.versionId = request["version_id"].get!string;
  }
  if ("environment" in request && request["environment"].isString) {
    testRun.environment = request["environment"].get!string;
  }
  if ("result_status" in request && request["result_status"].isString) {
    testRun.resultStatus = toLower(request["result_status"].get!string);
  }
  if ("passed_cases" in request && request["passed_cases"].type == Json.Type.int_) {
    testRun.passedCases = request["passed_cases"].get!long;
  }
  if ("failed_cases" in request && request["failed_cases"].type == Json.Type.int_) {
    testRun.failedCases = request["failed_cases"].get!long;
  }

  return testRun;
}

AgentryRuntimeInstance instanceFromJson(string tenantId, Json request) {
  AgentryRuntimeInstance instance;
  instance.tenantId = tenantId;
  instance.instanceId = randomUUID().toString();
  instance.targetEnvironment = "prod";
  instance.updatedAt = Clock.currTime();

  if ("instance_id" in request && request["instance_id"].isString) {
    instance.instanceId = request["instance_id"].get!string;
  }
  if ("app_id" in request && request["app_id"].isString) {
    instance.appId = request["app_id"].get!string;
  }
  if ("target_environment" in request && request["target_environment"].isString) {
    instance.targetEnvironment = request["target_environment"].get!string;
  }
  if ("deployed_version_id" in request && request["deployed_version_id"].isString) {
    instance.deployedVersionId = request["deployed_version_id"].get!string;
  }
  if ("status" in request && request["status"].isString) {
    instance.status = toLower(request["status"].get!string);
  }

  return instance;
}

AgentryDevice deviceFromJson(string tenantId, Json request) {
  AgentryDevice device;
  device.tenantId = tenantId;
  device.deviceId = randomUUID().toString();
  device.platform = "ios";
  device.lastSyncAt = Clock.currTime();

  if ("device_id" in request && request["device_id"].isString) {
    device.deviceId = request["device_id"].get!string;
  }
  if ("app_id" in request && request["app_id"].isString) {
    device.appId = request["app_id"].get!string;
  }
  if ("user_id" in request && request["user_id"].isString) {
    device.userId = request["user_id"].get!string;
  }
  if ("platform" in request && request["platform"].isString) {
    device.platform = toLower(request["platform"].get!string);
  }
  if ("app_version_id" in request && request["app_version_id"].isString) {
    device.appVersionId = request["app_version_id"].get!string;
  }

  return device;
}

AgentryBackendSystem backendFromJson(string tenantId, Json request) {
  AgentryBackendSystem backend;
  backend.tenantId = tenantId;
  backend.backendId = randomUUID().toString();
  backend.systemType = "s4hana";
  backend.authMode = "oauth2";
  backend.updatedAt = Clock.currTime();

  if ("backend_id" in request && request["backend_id"].isString) {
    backend.backendId = request["backend_id"].get!string;
  }
  if ("system_type" in request && request["system_type"].isString) {
    backend.systemType = toLower(request["system_type"].get!string);
  }
  if ("endpoint" in request && request["endpoint"].isString) {
    backend.endpoint = request["endpoint"].get!string;
  }
  if ("auth_mode" in request && request["auth_mode"].isString) {
    backend.authMode = toLower(request["auth_mode"].get!string);
  }
  if ("enabled" in request && request["enabled"].type == Json.Type.bool_) {
    backend.enabled = request["enabled"].get!bool;
  }

  return backend;
}
