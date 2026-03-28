module uim.sap.agentry.models.testrun;
import uim.sap.agentry;

mixin(ShowModule!());

@safe:
class AGTTestRun : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AGTTestRun);

  override bool initialize(Json[string] initData) {
    if (!super.initialize(initData)) {
      return false;
    }

    if ("app_id" in initData && initData["app_id"].isString) {
      appId = UUID(initData["app_id"].get!string);
    }
    if ("test_run_id" in initData && initData["test_run_id"].isString) {
      testRunId = UUID(initData["test_run_id"].get!string);
    }
    if ("version_id" in initData && initData["version_id"].isString) {
      versionId = UUID(initData["version_id"].get!string);
    }
    environment = initData.getString("environment", "default");
    resultStatus = toLower(initData.getString("result_status", "passed"));
    passedCases = initData.getLong("passed_cases", 0);
    failedCases = initData.getLong("failed_cases", 0);
    
    if ("executed_at" in initData && initData["executed_at"].isString) {
      executedAt = SysTime.fromISOExtString(initData["executed_at"].get!string);
    }

    testRunId = "testRunId" in initData ? UUID(initData["testRunId"].get!string) : randomUUID();
    environment = initData.getString("environment", "qa");
    resultStatus = initData.getString("resultStatus", "passed");
    executedAt = "executedAt" in initData ? SysTime.fromISOExtString(initData["executedAt"].get!string) : Clock.currTime();

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

    return testRun;
  }
}
