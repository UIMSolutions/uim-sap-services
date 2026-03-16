module uim.sap.agentry.models.testrun;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AgentryTestRun : SAPTenantObject {
  mixin(SAPObjectTemplate!AgentryTestRun);

  UUID appId;
  UUID testRunId;
  UUID versionId;
  string environment;
  string resultStatus;
  long passedCases;
  long failedCases;
  SysTime executedAt;

  override Json toJson() {
    Json result = super.toJson();
    result["app_id"] = appId.toString();
    result["test_run_id"] = testRunId.toString();
    result["version_id"] = versionId.toString();
    result["environment"] = environment;
    result["result_status"] = resultStatus;
    result["passed_cases"] = passedCases;
    result["failed_cases"] = failedCases;
    result["executed_at"] = executedAt.toISOExtString();
    return result;
  }
}

AgentryTestRun testRunFromJson(string tenantId, string appId, Json request) {
  AgentryTestRun testRun = new AgentryTestRun();
  testRun.tenantId = UUID(tenantId);
  testRun.appId = toUUID(appId);
  testRun.testRunId = randomUUID();
  testRun.environment = "qa";
  testRun.resultStatus = "passed";
  testRun.executedAt = Clock.currTime();

  if ("test_run_id" in request && request["test_run_id"].isString) {
    testRun.testRunId = toUUID(request["test_run_id"].get!string);
  }
  if ("version_id" in request && request["version_id"].isString) {
    testRun.versionId = toUUID(request["version_id"].get!string);
  }
  if ("environment" in request && request["environment"].isString) {
    testRun.environment = request["environment"].get!string;
  }
  if ("result_status" in request && request["result_status"].isString) {
    testRun.resultStatus = toLower(request["result_status"].get!string);
  }
  if ("passed_cases" in request && request["passed_cases"].isInteger) {
    testRun.passedCases = request["passed_cases"].get!long;
  }
  if ("failed_cases" in request && request["failed_cases"].isInteger) {
    testRun.failedCases = request["failed_cases"].get!long;
  }

  return testRun;
}