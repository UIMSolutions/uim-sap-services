module uim.sap.agentry.models.testrun;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTTestRun : SAPTenantObject {
  mixin(SAPObjectTemplate!AGTTestRun);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("app_id" in initData && initData["app_id"].isString) {
      appId = toUUID(initData["app_id"].get!string);
    }
    if ("test_run_id" in initData && initData["test_run_id"].isString) {
      testRunId = toUUID(initData["test_run_id"].get!string);
    }
    if ("version_id" in initData && initData["version_id"].isString) {
      versionId = toUUID(initData["version_id"].get!string);
    }
    if ("environment" in initData && initData["environment"].isString) {
      environment = initData["environment"].get!string;
    }
    if ("result_status" in initData && initData["result_status"].isString) {
      resultStatus = toLower(initData["result_status"].get!string);
    }
    if ("passed_cases" in initData && initData["passed_cases"].isInteger) {
      passedCases = initData["passed_cases"].get!long;
    }
    if ("failed_cases" in initData && initData["failed_cases"].isInteger) {
      failedCases = initData["failed_cases"].get!long;
    }
    if ("executed_at" in initData && initData["executed_at"].isString) {
      executedAt = SysTime.fromISOExtString(initData["executed_at"].get!string);
    }

    return true;
  }

  UUID appId;
  UUID testRunId;
  UUID versionId;
  string environment;
  string resultStatus;
  long passedCases;
  long failedCases;
  SysTime executedAt;

  override Json toJson() {
    return super.toJson()
      .set("app_id", appId.toString())
      .set("test_run_id", testRunId.toString())
      .set("version_id", versionId.toString())
      .set("environment", environment)
      .set("result_status", resultStatus)
      .set("passed_cases", passedCases)
      .set("failed_cases", failedCases)
      .set("executed_at", executedAt.toISOExtString());
  }

  static AGTTestRun opCall(UUID tenantId, string appId, Json request) {
    AGTTestRun testRun = new AGTTestRun(request);
    testRun.tenantId = tenantId;
    testRun.appId = toUUID(appId);
    testRun.testRunId = randomUUID();
    testRun.environment = "qa";
    testRun.resultStatus = "passed";
    testRun.executedAt = Clock.currTime();

    return testRun;
  }
}
