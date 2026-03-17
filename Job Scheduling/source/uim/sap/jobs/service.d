module uim.sap.jobs.service;

import core.thread : Thread;
import std.array : split;
import std.conv : to;
import std.datetime : Clock, SysTime, days, dur, hours, minutes, seconds;
import std.format : format;
import std.string : startsWith, toLower;

import vibe.data.json : Json;
import vibe.http.client : requestHTTP;
import vibe.http.common : HTTPMethod;

import uim.sap.jobs.config;
import uim.sap.jobs.exceptions;
import uim.sap.jobs.models;
import uim.sap.jobs.store;

class JobSchedulingService : SAPService {
  private JobSchedulingConfig _config;
  private JobSchedulingStore _store;
  private Thread _schedulerThread;
  private bool _schedulerRunning;

  this(JobSchedulingConfig config) {
    config.validate();
    _config = config;
    _store = new JobSchedulingStore;
    startScheduler();
  }

  ~this() {
    _schedulerRunning = false;
  }

  @property const(JobSchedulingConfig) config() const {
    return _config;
  }

  override Json health() {
    Json healthInfo = super.health();
    healthInfo["ok"] = true;
    healthInfo["serviceName"] = _config.serviceName;
    healthInfo["serviceVersion"] = _config.serviceVersion;
    healthInfo["scheduler_running"] = _schedulerRunning;
    return healthInfo;
  }

  string dashboardHtml() {
    return q"HTML
<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <title>UIM Job Scheduling Dashboard</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; }
    h1 { margin-bottom: 0.5rem; }
    .row { display: flex; gap: 1rem; margin-bottom: 1rem; }
    input, select, button, textarea { padding: 0.5rem; }
    textarea { width: 100%; min-height: 80px; }
    pre { background: #f6f8fa; padding: 1rem; overflow: auto; }
  </style>
</head>
<body>
  <h1>Job Scheduling Dashboard</h1>
  <p>Manage jobs, schedules, and monitor runs for a tenant.</p>

  <div class=\"row\">
    <input id=\"tenant\" value=\"acme\" placeholder=\"tenant\" />
    <button onclick=\"refreshAll()\">Refresh</button>
        <button onclick=\"testAlertConnector()\">Test Alert Connector</button>
        <button onclick=\"testCloudAlmConnector()\">Test Cloud ALM Connector</button>
  </div>

  <h3>Create Job</h3>
  <div class=\"row\">
    <input id=\"jobName\" placeholder=\"Job Name\" />
    <input id=\"jobEndpoint\" placeholder=\"Action Endpoint\" style=\"width:400px\" />
    <select id=\"jobMode\"><option>sync</option><option>async</option></select>
    <button onclick=\"createJob()\">Create</button>
  </div>

  <h3>Create Schedule</h3>
  <div class=\"row\">
    <input id=\"scheduleJobId\" placeholder=\"Job ID\" />
        <select id=\"scheduleFormat\">
            <option>repeat_interval</option>
            <option>human</option>
            <option>repeat_at</option>
            <option>cron</option>
        </select>
        <input
            id=\"scheduleExpr\"
            placeholder=\"Expression / seconds / ISO time / cron\"
            style=\"width:360px\"
        />
    <button onclick=\"createSchedule()\">Create</button>
  </div>

  <h3>Data</h3>
  <pre id=\"out\">Loading...</pre>

  <script>
    function tenant() { return document.getElementById('tenant').value || 'acme'; }
    function base() { return '/api/job-scheduling/v1/tenants/' + tenant(); }
        function adminBase() { return '/api/job-scheduling/v1/admin'; }

    async function refreshAll() {
      const [jobs, schedules, runs, alerts] = await Promise.all([
        fetch(base() + '/jobs').then(r => r.json()),
        fetch(base() + '/schedules').then(r => r.json()),
        fetch(base() + '/runs').then(r => r.json()),
        fetch(base() + '/alerts').then(r => r.json())
      ]);
            document.getElementById('out').textContent =
                JSON.stringify({jobs, schedules, runs, alerts}, null, 2);
    }

    async function createJob() {
      const payload = {
        name: document.getElementById('jobName').value,
        action_endpoint: document.getElementById('jobEndpoint').value,
        execution_mode: document.getElementById('jobMode').value,
        runtime: 'cloud-foundry'
      };
            await fetch(base() + '/jobs', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            });
      refreshAll();
    }

    async function createSchedule() {
      const format = document.getElementById('scheduleFormat').value;
      const expr = document.getElementById('scheduleExpr').value;
      const payload = { job_id: document.getElementById('scheduleJobId').value, format };
      if (format === 'repeat_interval') payload.repeat_interval_seconds = Number(expr || '60');
      if (format === 'human') payload.human_expression = expr || 'every 1 minute';
      if (format === 'repeat_at') payload.repeat_at = expr;
      if (format === 'cron') payload.cron = expr || '*/5 * * * *';

            await fetch(base() + '/schedules', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            });
      refreshAll();
    }

        async function testAlertConnector() {
            const payload = {
                tenant_id: tenant(),
                job_id: document.getElementById('scheduleJobId').value || 'job-test',
                run_id: 'run-test'
            };

            const response = await fetch(adminBase() + '/alerts/test', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            });

            const result = await response.json();
            document.getElementById('out').textContent = JSON.stringify({
                connector: 'alert',
                result
            }, null, 2);
        }

        async function testCloudAlmConnector() {
            const payload = {
                tenant_id: tenant(),
                job_id: document.getElementById('scheduleJobId').value || 'job-test',
                run_id: 'run-test',
                status: 'succeeded',
                runtime: 'cloud-foundry'
            };

            const response = await fetch(adminBase() + '/cloud-alm/test', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify(payload)
            });

            const result = await response.json();
            document.getElementById('out').textContent = JSON.stringify({
                connector: 'cloud_alm',
                result
            }, null, 2);
        }

    refreshAll();
  </script>
</body>
</html>
HTML";
  }

  Json supportedRuntimes() {
    Json runtimes = Json.emptyArray;
    runtimes ~= "cloud-foundry";
    runtimes ~= "kyma";

    Json data = Json.emptyObject;
    data["resources"] = runtimes;
    data["total_results"] = cast(long)runtimes.length;
    return data;
  }

  Json testAlertConnector(Json request) {
    Json data = Json.emptyObject;

    if (_config.alertEndpoint.length == 0) {
      data["success"] = false;
      data["connected"] = false;
      data["message"] = "JOBS_ALERT_ENDPOINT is not configured";
      return data;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = optionalString(request, "tenant_id", "connector-test");
    payload["alert_id"] = _store.nextId("alert-test");
    payload["event_type"] = "CONNECTOR_TEST";
    payload["job_id"] = optionalString(request, "job_id", "job-test");
    payload["run_id"] = optionalString(request, "run_id", "run-test");
    payload["status"] = "succeeded";
    payload["severity"] = "info";
    payload["message"] = optionalString(request, "message", "Alert connector test");
    payload["created_at"] = Clock.currTime().toISOExtString();

    sendAlertNotification(payload, true);

    data["success"] = true;
    data["connected"] = true;
    data["endpoint"] = _config.alertEndpoint;
    data["payload"] = payload;
    return data;
  }

  Json testCloudAlmConnector(Json request) {
    Json data = Json.emptyObject;

    if (_config.cloudAlmEndpoint.length == 0) {
      data["success"] = false;
      data["connected"] = false;
      data["message"] = "JOBS_CLOUD_ALM_ENDPOINT is not configured";
      return data;
    }

    Json payload = Json.emptyObject;
    payload["tenant_id"] = optionalString(request, "tenant_id", "connector-test");
    payload["run_id"] = optionalString(request, "run_id", "run-test");
    payload["job_id"] = optionalString(request, "job_id", "job-test");
    payload["status"] = optionalString(request, "status", "succeeded");
    payload["runtime"] = optionalString(request, "runtime", "cloud-foundry");
    payload["started_at"] = Clock.currTime().toISOExtString();
    payload["finished_at"] = Clock.currTime().toISOExtString();

    sendCloudAlmTelemetry(payload, true);

    data["success"] = true;
    data["connected"] = true;
    data["endpoint"] = _config.cloudAlmEndpoint;
    data["payload"] = payload;
    return data;
  }

  Json createJob(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    Job item;
    item.tenantId = UUID(tenantId);
    item.jobId = optionalString(request, "job_id", _store.nextId("job"));
    item.name = requiredString(request, "name");
    item.description = optionalString(request, "description", "");
    item.actionEndpoint = optionalString(request, "action_endpoint", "");
    item.httpMethod = toUpper(optionalString(request, "http_method", "POST"));
    item.payload = optionalObject(request, "payload");
    item.runtime = optionalString(request, "runtime", "cloud-foundry");
    item.executionMode = optionalString(request, "execution_mode", "sync");
    item.longRunningTask = request.getBoolean((request, "long_running_task", false);
    item.oauthToken = optionalString(request, "oauth_token", "");
    item.active = request.getBoolean((request, "active", true);
    item.createdAt = Clock.currTime();
    item.updatedAt = item.createdAt;

    ensureRuntime(item.runtime);
    ensureExecutionMode(item.executionMode);

    auto saved = _store.upsertJob(item);

    Json data = Json.emptyObject;
    data["success"] = true;
    data["job"] = saved.toJson();
    return data;
  }

  Json listJobs(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (item; _store.listJobs(tenantId))
      resources ~= item.toJson();

    Json data = Json.emptyObject;
    data["resources"] = resources;
    data["total_results"] = cast(long)resources.length;
    return data;
  }

  Json getJob(string tenantId, string jobId) {
    validateId(tenantId, "Tenant ID");
    validateId(jobId, "Job ID");

    Job item;
    if (!_store.getJob(tenantId, jobId, item)) {
      throw new JobSchedulingNotFoundException("Job", jobId);
    }

    Json data = Json.emptyObject;
    data["job"] = item.toJson();
    return data;
  }

  Json updateJob(string tenantId, string jobId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(jobId, "Job ID");

    Job item;
    if (!_store.getJob(tenantId, jobId, item)) {
      throw new JobSchedulingNotFoundException("Job", jobId);
    }

    item.name = optionalString(request, "name", item.name);
    item.description = optionalString(request, "description", item.description);
    item.actionEndpoint = optionalString(request, "action_endpoint", item.actionEndpoint);
    item.httpMethod = toUpper(optionalString(request, "http_method", item.httpMethod));
    if ("payload" in request && request["payload"].isObject)
      item.payload = request["payload"];
    item.runtime = optionalString(request, "runtime", item.runtime);
    item.executionMode = optionalString(request, "execution_mode", item.executionMode);
    item.longRunningTask = request.getBoolean((request, "long_running_task", item.longRunningTask);
    item.oauthToken = optionalString(request, "oauth_token", item.oauthToken);
    item.active = request.getBoolean((request, "active", item.active);
    item.updatedAt = Clock.currTime();

    ensureRuntime(item.runtime);
    ensureExecutionMode(item.executionMode);

    auto saved = _store.upsertJob(item);

    Json data = Json.emptyObject;
    data["success"] = true;
    data["job"] = saved.toJson();
    return data;
  }

  Json deleteJob(string tenantId, string jobId) {
    validateId(tenantId, "Tenant ID");
    validateId(jobId, "Job ID");

    if (!_store.deleteJob(tenantId, jobId)) {
      throw new JobSchedulingNotFoundException("Job", jobId);
    }

    Json data = Json.emptyObject;
    data["success"] = true;
    data["job_id"] = jobId;
    return data;
  }

  Json createSchedule(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto jobId = requiredString(request, "job_id");
    Job job;
    if (!_store.getJob(tenantId, jobId, job)) {
      throw new JobSchedulingNotFoundException("Job", jobId);
    }

    Schedule item;
    item.tenantId = UUID(tenantId);
    item.scheduleId = optionalString(request, "schedule_id", _store.nextId("schedule"));
    item.jobId = jobId;
    item.format = optionalString(request, "format", "repeat_interval");
    item.humanExpression = optionalString(request, "human_expression", "");
    item.repeatAt = optionalString(request, "repeat_at", "");
    item.repeatIntervalSeconds = request.getInteger("repeat_interval_seconds", 60);
    item.cron = optionalString(request, "cron", "");
    item.timezone = optionalString(request, "timezone", "UTC");
    item.active = request.getBoolean((request, "active", true);
    item.nextRunAt = nextRunFor(item, Clock.currTime());
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertSchedule(item);

    Json data = Json.emptyObject;
    data["success"] = true;
    data["schedule"] = saved.toJson();
    return data;
  }

  Json listSchedules(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (item; _store.listSchedules(tenantId))
      resources ~= item.toJson();

    Json data = Json.emptyObject;
    data["resources"] = resources;
    data["total_results"] = cast(long)resources.length;
    return data;
  }

  Json getSchedule(string tenantId, string scheduleId) {
    validateId(tenantId, "Tenant ID");
    validateId(scheduleId, "Schedule ID");

    Schedule item;
    if (!_store.getSchedule(tenantId, scheduleId, item)) {
      throw new JobSchedulingNotFoundException("Schedule", scheduleId);
    }

    Json data = Json.emptyObject;
    data["schedule"] = item.toJson();
    return data;
  }

  Json updateSchedule(string tenantId, string scheduleId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(scheduleId, "Schedule ID");

    Schedule item;
    if (!_store.getSchedule(tenantId, scheduleId, item)) {
      throw new JobSchedulingNotFoundException("Schedule", scheduleId);
    }

    item.format = optionalString(request, "format", item.format);
    item.humanExpression = optionalString(request, "human_expression", item.humanExpression);
    item.repeatAt = optionalString(request, "repeat_at", item.repeatAt);
    item.repeatIntervalSeconds = optionalInt(
      request,
      "repeat_interval_seconds",
      item.repeatIntervalSeconds
    );
    item.cron = optionalString(request, "cron", item.cron);
    item.timezone = optionalString(request, "timezone", item.timezone);
    item.active = request.getBoolean((request, "active", item.active);
    item.nextRunAt = nextRunFor(item, Clock.currTime());
    item.updatedAt = Clock.currTime();

    auto saved = _store.upsertSchedule(item);

    Json data = Json.emptyObject;
    data["success"] = true;
    data["schedule"] = saved.toJson();
    return data;
  }

  Json deleteSchedule(string tenantId, string scheduleId) {
    validateId(tenantId, "Tenant ID");
    validateId(scheduleId, "Schedule ID");

    if (!_store.deleteSchedule(tenantId, scheduleId)) {
      throw new JobSchedulingNotFoundException("Schedule", scheduleId);
    }

    Json data = Json.emptyObject;
    data["success"] = true;
    data["schedule_id"] = scheduleId;
    return data;
  }

  Json runJobNow(string tenantId, string jobId, Json request) {
    validateId(tenantId, "Tenant ID");
    validateId(jobId, "Job ID");

    Job job;
    if (!_store.getJob(tenantId, jobId, job)) {
      throw new JobSchedulingNotFoundException("Job", jobId);
    }

    auto mode = optionalString(request, "execution_mode", job.executionMode);
    ensureExecutionMode(mode);

    auto run = createRun(tenantId, jobId, "manual", job.runtime, mode == "async");
    if (mode == "async" || job.longRunningTask) {
      auto runId = run.runId;
      auto scheduleId = run.scheduleId;
      auto worker = new Thread({
        executeRun(tenantId, job, runId, scheduleId, true);
      });
      worker.isDaemon = true;
      worker.start();
    } else {
      executeRun(tenantId, job, run.runId, run.scheduleId, false);
      if (auto refreshed = runById(tenantId, run.runId))
        run = *refreshed;
    }

    Json data = Json.emptyObject;
    data["success"] = true;
    data["run"] = run.toJson();
    return data;
  }

  Json runCFTask(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto taskName = optionalString(request, "task_name", "cf-task");
    auto durationSeconds = request.getInteger("duration_seconds", 30);

    CFTaskRun task;
    task.tenantId = UUID(tenantId);
    task.taskRunId = _store.nextId("cftask");
    task.taskName = taskName;
    task.durationSeconds = durationSeconds;
    task.status = "running";
    task.startedAt = Clock.currTime();
    task.finishedAt = task.startedAt;

    auto saved = _store.upsertCFTaskRun(task);

    auto taskRunId = saved.taskRunId;
    auto worker = new Thread({
      Thread.sleep(dur!"seconds"(durationSeconds));

      CFTaskRun update;
      update.tenantId = UUID(tenantId);
      update.taskRunId = taskRunId;
      update.taskName = taskName;
      update.durationSeconds = durationSeconds;
      update.status = "succeeded";
      update.startedAt = task.startedAt;
      update.finishedAt = Clock.currTime();
      _store.upsertCFTaskRun(update);
    });
    worker.isDaemon = true;
    worker.start();

    Json data = Json.emptyObject;
    data["success"] = true;
    data["task_run"] = saved.toJson();
    return data;
  }

  Json listCFTaskRuns(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (item; _store.listCFTaskRuns(tenantId))
      resources ~= item.toJson();

    Json data = Json.emptyObject;
    data["resources"] = resources;
    data["total_results"] = cast(long)resources.length;
    return data;
  }

  Json listRuns(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (item; _store.listRuns(tenantId))
      resources ~= item.toJson();

    Json data = Json.emptyObject;
    data["resources"] = resources;
    data["total_results"] = cast(long)resources.length;
    return data;
  }

  Json listAlerts(string tenantId) {
    validateId(tenantId, "Tenant ID");
    Json resources = Json.emptyArray;
    foreach (item; _store.listAlerts(tenantId))
      resources ~= item.toJson();

    Json data = Json.emptyObject;
    data["resources"] = resources;
    data["total_results"] = cast(long)resources.length;
    return data;
  }

  Json dashboardData(string tenantId) {
    validateId(tenantId, "Tenant ID");

    auto jobs = _store.listJobs(tenantId);
    auto schedules = _store.listSchedules(tenantId);
    auto runs = _store.listRuns(tenantId);
    auto alerts = _store.listAlerts(tenantId);
    auto tasks = _store.listCFTaskRuns(tenantId);

    Json data = Json.emptyObject;
    data["tenant_id"] = tenantId;
    data["jobs"] = cast(long)jobs.length;
    data["schedules"] = cast(long)schedules.length;
    data["runs"] = cast(long)runs.length;
    data["alerts"] = cast(long)alerts.length;
    data["cf_tasks"] = cast(long)tasks.length;
    return data;
  }

  private void startScheduler() {
    _schedulerRunning = true;
    _schedulerThread = new Thread({ schedulerLoop(); });
    _schedulerThread.isDaemon = true;
    _schedulerThread.start();
  }

  private void schedulerLoop() {
    while (_schedulerRunning) {
      try {
        auto now = Clock.currTime();
        foreach (schedule; _store.listDueSchedules(now)) {
          executeScheduledRun(schedule);
        }
      } catch (Exception) {
      }

      Thread.sleep(dur!"msecs"(_config.schedulerTickMs));
    }
  }

  private void executeScheduledRun(Schedule schedule) {
    Job job;
    if (!_store.getJob(schedule.tenantId, schedule.jobId, job))
      return;
    if (!job.active)
      return;

    auto run = createRun(
      schedule.tenantId,
      schedule.jobId,
      schedule.scheduleId,
      job.runtime,
      job.executionMode == "async" || job.longRunningTask
    );

    if (run.asyncRun) {
      auto tenantId = run.tenantId;
      auto runId = run.runId;
      auto scheduleId = run.scheduleId;
      auto worker = new Thread({
        executeRun(tenantId, job, runId, scheduleId, true);
      });
      worker.isDaemon = true;
      worker.start();
    } else {
      executeRun(run.tenantId, job, run.runId, run.scheduleId, false);
    }

    schedule.nextRunAt = nextRunFor(schedule, Clock.currTime());
    if (schedule.format == "repeat_at") {
      schedule.active = false;
    }
    schedule.updatedAt = Clock.currTime();
    _store.upsertSchedule(schedule);
  }

  private RunLog createRun(
    string tenantId,
    string jobId,
    string scheduleId,
    string runtime,
    bool asyncRun
  ) {
    RunLog run;
    run.tenantId = UUID(tenantId);
    run.runId = _store.nextId("run");
    run.jobId = jobId;
    run.scheduleId = scheduleId;
    run.runtime = runtime;
    run.asyncRun = asyncRun;
    run.status = asyncRun ? "queued" : "running";
    run.responseCode = 0;
    run.message = asyncRun ? "queued for asynchronous execution" : "running";
    run.startedAt = Clock.currTime();
    run.finishedAt = run.startedAt;
    return _store.upsertRun(run);
  }

  private void executeRun(
    string tenantId,
    Job job,
    string runId,
    string scheduleId,
    bool asyncRun
  ) {
    auto currentRun = runById(tenantId, runId);
    if (!currentRun)
      return;

    auto run = *currentRun;
    run.status = "running";
    run.message = "running";
    _store.upsertRun(run);

    if (asyncRun || job.longRunningTask) {
      Thread.sleep(dur!"seconds"(3));
    }

    bool success = true;
    int statusCode = 200;
    string message = "executed";

    try {
      invokeActionEndpoint(job);
    } catch (Exception e) {
      success = false;
      statusCode = 500;
      message = e.msg;
    }

    run.status = success ? "succeeded" : "failed";
    run.responseCode = statusCode;
    run.message = message;
    run.finishedAt = Clock.currTime();
    _store.upsertRun(run);

    emitAlert(run, success ? "JOB_SUCCEEDED" : "JOB_FAILED", message);
    pushCloudAlm(run);
  }

  private RunLog* runById(string tenantId, string runId) {
    foreach (item; _store.listRuns(tenantId)) {
      if (item.runId == runId) {
        auto copy = new RunLog;
        *copy = item;
        return copy;
      }
    }
    return null;
  }

  private void invokeActionEndpoint(Job job) {
    if (job.actionEndpoint.length == 0)
      return;

    requestHTTP(job.actionEndpoint,
      (scope req) {
      req.method = toHttpMethod(job.httpMethod);
      req.headers["Accept"] = "application/json";
      req.headers["Content-Type"] = "application/json";

      auto token = job.oauthToken.length > 0
        ? job.oauthToken : _config.outboundOauthToken;
      if (token.length > 0) {
        req.headers["Authorization"] = "Bearer " ~ token;
      }

      if (
        req.method == HTTPMethod.POST ||
      req.method == HTTPMethod.PUT ||
      req.method == HTTPMethod.PATCH
        ) {
        req.writeJsonBody(job.payload);
      }
    },
      (scope res) {
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw new JobSchedulingException(
          format("Action endpoint returned status %d", res.statusCode)
        );
      }
    }
    );
  }

  private void emitAlert(RunLog run, string eventType, string message) {
    AlertEvent alert;
    alert.tenantId = run.tenantId;
    alert.alertId = _store.nextId("alert");
    alert.eventType = eventType;
    alert.jobId = run.jobId;
    alert.runId = run.runId;
    alert.status = run.status;
    alert.severity = run.status == "failed" ? "critical" : "info";
    alert.message = message;
    alert.createdAt = Clock.currTime();
    _store.upsertAlert(alert);

    sendAlertNotification(alert.toJson(), false);
  }

  private void pushCloudAlm(RunLog run) {
    Json payload = Json.emptyObject;
    payload["tenant_id"] = run.tenantId;
    payload["run_id"] = run.runId;
    payload["job_id"] = run.jobId;
    payload["status"] = run.status;
    payload["runtime"] = run.runtime;
    payload["started_at"] = run.startedAt.toISOExtString();
    payload["finished_at"] = run.finishedAt.toISOExtString();

    sendCloudAlmTelemetry(payload, false);
  }

  private void sendAlertNotification(Json payload, bool strict) {
    if (_config.alertEndpoint.length == 0) {
      if (strict) {
        throw new JobSchedulingValidationException("JOBS_ALERT_ENDPOINT is not configured");
      }
      return;
    }

    try {
      requestHTTP(_config.alertEndpoint,
        (scope req) {
        req.method = HTTPMethod.POST;
        req.headers["Accept"] = "application/json";
        req.headers["Content-Type"] = "application/json";
        if (_config.alertApiKey.length > 0) {
          req.headers["X-API-Key"] = _config.alertApiKey;
        }
        req.writeJsonBody(payload);
      },
        (scope res) {
        if (strict && (res.statusCode < 200 || res.statusCode >= 300)) {
          throw new JobSchedulingException(
            format("Alert endpoint returned status %d", res.statusCode)
          );
        }
      }
      );
    } catch (Exception e) {
      if (strict) {
        throw new JobSchedulingException("Alert connector test failed: " ~ e.msg);
      }
    }
  }

  private void sendCloudAlmTelemetry(Json payload, bool strict) {
    if (_config.cloudAlmEndpoint.length == 0) {
      if (strict) {
        throw new JobSchedulingValidationException(
          "JOBS_CLOUD_ALM_ENDPOINT is not configured"
        );
      }
      return;
    }

    try {
      requestHTTP(_config.cloudAlmEndpoint,
        (scope req) {
        req.method = HTTPMethod.POST;
        req.headers["Accept"] = "application/json";
        req.headers["Content-Type"] = "application/json";
        if (_config.cloudAlmApiKey.length > 0) {
          req.headers["X-API-Key"] = _config.cloudAlmApiKey;
        }
        req.writeJsonBody(payload);
      },
        (scope res) {
        if (strict && (res.statusCode < 200 || res.statusCode >= 300)) {
          throw new JobSchedulingException(
            format("Cloud ALM endpoint returned status %d", res.statusCode)
          );
        }
      }
      );
    } catch (Exception e) {
      if (strict) {
        throw new JobSchedulingException("Cloud ALM connector test failed: " ~ e.msg);
      }
    }
  }

  private SysTime nextRunFor(Schedule schedule, SysTime now) {
    auto formatName = toLower(schedule.format);

    if (formatName == "repeat_at") {
      if (schedule.repeatAt.length == 0) {
        throw new JobSchedulingValidationException("repeat_at requires repeat_at field");
      }

      try {
        return SysTime.fromISOExtString(schedule.repeatAt);
      } catch (Exception) {
        throw new JobSchedulingValidationException("repeat_at must be ISO datetime");
      }
    }

    if (formatName == "repeat_interval") {
      auto secondsValue = schedule.repeatIntervalSeconds > 0
        ? schedule.repeatIntervalSeconds : 60;
      return now + dur!"seconds"(secondsValue);
    }

    if (formatName == "human") {
      return parseHumanExpression(schedule.humanExpression, now);
    }

    if (formatName == "cron") {
      return parseCronExpression(schedule.cron, now);
    }

    throw new JobSchedulingValidationException("Unknown schedule format");
  }

  private SysTime parseHumanExpression(string expression, SysTime now) {
    auto value = toLower(expression);
    if (value.length == 0)
      return now + minutes(1);

    if (value == "hourly")
      return now + hours(1);
    if (value == "daily")
      return now + days(1);

    if (startsWith(value, "every ")) {
      auto rest = value[6 .. $];
      auto parts = rest.split(" ");
      if (parts.length >= 2) {
        int amount = 1;
        try {
          amount = parts[0].to!int;
        } catch (Exception) {
          amount = 1;
        }

        auto unit = parts[1];
        if (unit.startsWith("second"))
          return now + dur!"seconds"(amount);
        if (unit.startsWith("minute"))
          return now + dur!"minutes"(amount);
        if (unit.startsWith("hour"))
          return now + dur!"hours"(amount);
        if (unit.startsWith("day"))
          return now + dur!"days"(amount);
      }
    }

    return now + minutes(1);
  }

  private SysTime parseCronExpression(string cron, SysTime now) {
    auto value = toLower(cron);
    if (value.length == 0)
      return now + minutes(5);

    auto parts = value.split(" ");
    if (parts.length < 5)
      return now + minutes(5);

    if (parts[0].startsWith("*/")) {
      int n = parsePositive(parts[0][2 .. $], 5);
      return now + minutes(n);
    }

    if (parts[0] == "0" && parts[1].startsWith("*/")) {
      int n = parsePositive(parts[1][2 .. $], 1);
      return now + hours(n);
    }

    if (parts[0] == "0" && parts[1] == "0") {
      return now + days(1);
    }

    return now + minutes(5);
  }

  private int parsePositive(string value, int fallback) {
    try {
      auto parsed = value.to!int;
      return parsed > 0 ? parsed : fallback;
    } catch (Exception) {
      return fallback;
    }
  }

  private HTTPMethod toHttpMethod(string methodName) {
    auto normalized = toUpper(methodName);
    switch (normalized) {
    case "GET":
      return HTTPMethod.GET;
    case "POST":
      return HTTPMethod.POST;
    case "PUT":
      return HTTPMethod.PUT;
    case "PATCH":
      return HTTPMethod.PATCH;
    case "DELETE":
      return HTTPMethod.DELETE;
    default:
      return HTTPMethod.POST;
    }
  }

  private string toUpper(string value) {
    string output;
    foreach (ch; value) {
      if (ch >= 'a' && ch <= 'z') {
        output ~= cast(char)(ch - 32);
      } else {
        output ~= ch;
      }
    }
    return output;
  }

  private void ensureRuntime(string runtime) {
    auto normalized = toLower(runtime);
    if (normalized != "cloud-foundry" && normalized != "kyma") {
      throw new JobSchedulingValidationException("runtime must be cloud-foundry or kyma");
    }
  }

  private void ensureExecutionMode(string mode) {
    auto normalized = toLower(mode);
    if (normalized != "sync" && normalized != "async") {
      throw new JobSchedulingValidationException("execution_mode must be sync or async");
    }
  }

  private string requiredString(Json request, string key) {
    if (!(key in request) || request[key].type != Json.Type.string) {
      throw new JobSchedulingValidationException(key ~ " is required");
    }
    auto value = request[key].get!string;
    if (value.length == 0) {
      throw new JobSchedulingValidationException(key ~ " cannot be empty");
    }
    return value;
  }

  private string optionalString(Json request, string key, string fallback) {
    if (key in request && request[key].isString) {
      auto value = request[key].get!string;
      return value.length > 0 ? value : fallback;
    }
    return fallback;
  }
}
