module uim.sap.cia.service;
import uim.sap.cia;

mixin(ShowModule!());

@safe:


// ---------------------------------------------------------------------------
// CIAService – orchestrates all domain logic
// ---------------------------------------------------------------------------
class CIAService : SAPService {
  mixin(SAPServiceTemplate!CIAService);

  private CIAStore _store;

  this(CIAConfig config) {
    super(config);

    _store = new CIAStore;
    _seedDefaultData();
  }

  // -----------------------------------------------------------------------
  // Health / readiness
  // -----------------------------------------------------------------------
  override Json health()  {
    return super.health()
    .set("runtime", (cast(CIAConfig)_config).runtime)
    .set("multitenancy", true)
    .set("domain", "cloud-integration-automation");
  }

  // -----------------------------------------------------------------------
  // Dashboard HTML
  // -----------------------------------------------------------------------
  string dashboardHtml() const {
    return q"HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <title>Cloud Integration Automation</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; max-width: 1280px; }
    h1   { margin-bottom: 0.2rem; }
    h3   { margin-top: 1.4rem; margin-bottom: 0.3rem; }
    .row { display:flex; gap:0.6rem; flex-wrap:wrap; margin:0.4rem 0; align-items:center; }
    input, select, textarea, button { padding:0.45rem 0.7rem; font-size:0.95rem; }
    textarea { width:100%; height:5rem; }
    button   { cursor:pointer; background:#0a6ed1; color:#fff; border:none; border-radius:4px; }
    button:hover { background:#085caf; }
    pre { background:#f6f8fa; padding:1rem; overflow:auto; border-radius:6px; max-height:420px; }
    .badge { display:inline-block; padding:2px 8px; border-radius:10px; font-size:0.8rem; font-weight:bold; }
    .planned   { background:#e8f5e9; color:#2e7d32; }
    .running   { background:#fff3e0; color:#e65100; }
    .completed { background:#e3f2fd; color:#0288d1; }
    .failed    { background:#fce4ec; color:#c62828; }
  </style>
</head>
<body>
  <h1>Cloud Integration Automation Service</h1>
  <p>Guided workflow service for integrating SAP Cloud solutions to On-Premises and other SAP Cloud solutions.</p>

  <div class="row">
    <label><b>Tenant:</b></label>
    <input id="tenant" value="acme" placeholder="tenant id" style="width:140px"/>
    <button onclick="refreshAll()">&#8635; Refresh</button>
  </div>

  <h3>System Landscape</h3>
  <div class="row">
    <input id="sysId"   placeholder="system id"   style="width:120px"/>
    <input id="sysName" placeholder="system name" style="width:180px"/>
    <select id="sysType">
      <option value="s4hana-cloud">S/4HANA Cloud</option>
      <option value="s4hana-on-prem">S/4HANA On-Premises</option>
      <option value="successfactors">SuccessFactors</option>
      <option value="ariba">SAP Ariba</option>
      <option value="integration-suite">Integration Suite</option>
      <option value="other">Other</option>
    </select>
    <input id="sysHost" placeholder="host / URL" style="width:280px"/>
    <button onclick="createSystem()">Add System</button>
  </div>

  <h3>Integration Scenarios</h3>
  <div class="row">
    <button onclick="listScenarios()">List Scenarios</button>
  </div>

  <h3>Plan Workflow</h3>
  <div class="row">
    <input id="wfScenarioId" placeholder="scenario id" style="width:140px"/>
    <input id="wfName"       placeholder="workflow name" style="width:220px"/>
    <input id="wfSystemIds"  placeholder="system ids (comma separated)" style="width:280px"/>
    <button onclick="planWorkflow()">Plan Workflow</button>
  </div>
  <div class="row">
    <input id="wfId" placeholder="workflow id" style="width:160px"/>
    <button onclick="startWorkflow()">Start</button>
    <button onclick="completeWorkflow()">Complete</button>
    <button onclick="getWorkflow()">Get Detail</button>
    <button onclick="listLogs()">View Logs</button>
  </div>

  <h3>Tasks</h3>
  <div class="row">
    <input id="taskWfId"  placeholder="workflow id" style="width:160px"/>
    <button onclick="listTasks()">List Tasks</button>
  </div>
  <div class="row">
    <input id="taskId"     placeholder="task id"   style="width:140px"/>
    <input id="taskRoleId" placeholder="role id"   style="width:100px"/>
    <input id="taskUserId" placeholder="user id"   style="width:100px"/>
    <button onclick="assignTask()">Assign</button>
    <select id="taskStatus">
      <option value="in-progress">in-progress</option>
      <option value="done">done</option>
      <option value="failed">failed</option>
      <option value="skipped">skipped</option>
    </select>
    <button onclick="progressTask()">Progress</button>
    <button onclick="automateTask()">Run Automation</button>
  </div>

  <h3>Parameters</h3>
  <div class="row">
    <input id="paramWfId"  placeholder="workflow id"  style="width:160px"/>
    <input id="paramKey"   placeholder="key"          style="width:120px"/>
    <input id="paramValue" placeholder="value"        style="width:160px"/>
    <input id="paramDesc"  placeholder="description"  style="width:180px"/>
    <label><input type="checkbox" id="paramSensitive"/> sensitive</label>
    <button onclick="setParameter()">Set Parameter</button>
    <button onclick="listParameters()">List Parameters</button>
  </div>

  <h3>Result</h3>
  <pre id="out">Click an action above…</pre>

<script>
const $ = id => document.getElementById(id);
const tenant = () => $('tenant').value.trim() || 'acme';
const base   = () => `/api/cloud-integration-automation/v1/tenants/${tenant()}`;

async function api(method, path, body) {
  const opts = { method, headers: { 'Content-Type': 'application/json' } };
  if (body) opts.body = JSON.stringify(body);
  const r = await fetch(path, opts);
  return r.json();
}

const show = d => $('out').textContent = JSON.stringify(d, null, 2);

async function refreshAll() {
  const [systems, scenarios, workflows] = await Promise.all([
    api('GET', base() + '/systems'),
    api('GET', '/api/cloud-integration-automation/v1/scenarios'),
    api('GET', base() + '/workflows')
  ]);
  show({ systems, scenarios, workflows });
}

async function listScenarios() { show(await api('GET', '/api/cloud-integration-automation/v1/scenarios')); }
async function createSystem() {
  show(await api('POST', base() + '/systems', {
    id: $('sysId').value, name: $('sysName').value,
    system_type: $('sysType').value, host: $('sysHost').value, active: true
  }));
}
async function planWorkflow() {
  show(await api('POST', base() + '/workflows', {
    scenario_id: $('wfScenarioId').value,
    name: $('wfName').value,
    system_ids: $('wfSystemIds').value.split(',').map(s => s.trim()).filter(Boolean)
  }));
}
async function getWorkflow()     { show(await api('GET',  base() + '/workflows/' + $('wfId').value)); }
async function startWorkflow()   { show(await api('POST', base() + '/workflows/' + $('wfId').value + '/start',    {})); }
async function completeWorkflow(){ show(await api('POST', base() + '/workflows/' + $('wfId').value + '/complete', {})); }
async function listLogs()        { show(await api('GET',  base() + '/workflows/' + $('wfId').value + '/logs')); }
async function listTasks()       { show(await api('GET',  base() + '/workflows/' + $('taskWfId').value + '/tasks')); }

async function assignTask() {
  show(await api('POST', base() + '/workflows/' + $('taskWfId').value + '/tasks/' + $('taskId').value + '/assign', {
    role_id: $('taskRoleId').value, user_id: $('taskUserId').value
  }));
}
async function progressTask() {
  show(await api('POST', base() + '/workflows/' + $('taskWfId').value + '/tasks/' + $('taskId').value + '/progress', {
    status: $('taskStatus').value
  }));
}
async function automateTask() {
  show(await api('POST', base() + '/workflows/' + $('taskWfId').value + '/tasks/' + $('taskId').value + '/automate', {}));
}
async function setParameter() {
  show(await api('POST', base() + '/workflows/' + $('paramWfId').value + '/parameters', {
    key: $('paramKey').value, value: $('paramValue').value,
    description: $('paramDesc').value, sensitive: $('paramSensitive').checked
  }));
}
async function listParameters() {
  show(await api('GET', base() + '/workflows/' + $('paramWfId').value + '/parameters'));
}
</script>
</body>
</html>
HTML";
  }

  // -----------------------------------------------------------------------
  // Roles
  // -----------------------------------------------------------------------
  Json listRoles() {
    Json arr = Json.emptyArray;
    foreach (r; _store.listRoles())
      arr ~= r.toJson();
    return arr;
  }

  Json upsertRole(Json payload) {
    auto role = CIARole(
      payload["id"].get!string,
      payload["name"].get!string,
      !payload.isNull && "description" in payload
        ? payload["description"].get!string : ""
    );
    return _store.upsertRole(role).toJson();
  }

  // -----------------------------------------------------------------------
  // Systems landscape
  // -----------------------------------------------------------------------
  Json listSystems(UUID tenantId) {
    Json arr = Json.emptyArray;
    foreach (s; _store.listSystems(tenantId))
      arr ~= s.toJson();
    return arr;
  }

  Json upsertSystem(UUID tenantId, Json payload) {
    import std.datetime : Clock;

    CIASystem sys = new CIASystem(payload);
    sys.tenantId = tenantId;
    sys.id = UUID(payload["id"].get!string);
    sys.name = payload["name"].getString;
    sys.systemType = "system_type" in payload ? payload["system_type"].get!string : "other";
    sys.host = "host" in payload ? payload["host"].get!string : "";
    sys.description = "description" in payload ? payload["description"].get!string : "";
    sys.active = "active" in payload ? payload["active"].get!bool : true;
    sys.createdAt = Clock.currTime();
    sys.updatedAt = Clock.currTime();
    return _store.upsertSystem(sys).toJson();
  }

  Json getSystem(UUID tenantId, UUID id) {
    CIASystem sys = new CIASystem;
    if (!_store.tryGetSystem(tenantId, id, sys))
      throw new CIANotFoundException("System not found: " ~ id);
    return sys.toJson();
  }

  // -----------------------------------------------------------------------
  // Scenarios
  // -----------------------------------------------------------------------
  Json listScenarios() {
    Json arr = Json.emptyArray;
    foreach (s; _store.listScenarios())
      arr ~= s.toJson();
    return arr;
  }

  Json getScenario(UUID id) {
    CIAScenario sc = new CIAScenario;
    if (!_store.tryGetScenario(id, sc))
      throw new CIANotFoundException("Scenario not found: " ~ id);
    return sc.toJson();
  }

  // -----------------------------------------------------------------------
  // Workflows – planning, start, complete
  // -----------------------------------------------------------------------
  Json listWorkflows(UUID tenantId) {
    Json arr = Json.emptyArray;
    foreach (w; _store.listWorkflows(tenantId))
      arr ~= w.toJson();
    return arr;
  }

  /// Plan a new workflow from a scenario and return it with generated tasks
  Json planWorkflow(UUID tenantId, Json payload) {
    auto scenarioId = payload["scenario_id"].getString;
    CIAScenario sc = new CIAScenario;
    if (!_store.tryGetScenario(scenarioId, sc))
      throw new CIANotFoundException("Scenario not found: " ~ scenarioId);

    // Collect system ids
    string[] sysIds;
    if ("system_ids" in payload && payload["system_ids"].isArray)
      foreach (s; payload["system_ids"].toArray)
        sysIds ~= s.getString;

    auto wfId = UUID(_store.nextId("wf"));
    CIAWorkflow wf = new CIAWorkflow;
    wf.tenantId = tenantId;
    wf.id = wfId;
    wf.scenarioId = scenarioId;
    wf.scenarioName = sc.name;
    wf.name = "name" in payload ? payload["name"].get!string : sc.name;
    wf.status = "planned";
    wf.systemIds = sysIds;
    wf.createdAt = Clock.currTime();
    wf.updatedAt = Clock.currTime();
    _store.upsertWorkflow(wf);

    _appendLog(tenantId, wfId, "", "info",
      "Workflow planned: " ~ wf.name ~ " (scenario: " ~ sc.name ~ ")");

    // Generate tasks from scenario templates
    foreach (tmpl; sc.taskTemplates) {
      auto taskId = UUID(_store.nextId("task"));

      // Render instructions – substitute {{systemList}} placeholder
      string instr = tmpl.instructions.replace("{{systemList}}", _buildSystemList(tenantId, sysIds));

      CIATask task = new CIATask;
      task.tenantId = tenantId;
      task.workflowId = wfId;
      task.id = taskId;
      task.order = tmpl.order;
      task.name = tmpl.name;
      task.description = tmpl.description;
      task.instructions = instr;
      task.assignedRoleId = tmpl.defaultRoleId;
      task.automated = tmpl.automated;
      task.status = "pending";
      task.context = Json.emptyObject;
      task.createdAt = Clock.currTime();
      task.updatedAt = Clock.currTime();
      _store.upsertTask(task);

      _appendLog(tenantId, wfId, taskId, "info",
        "Task created: " ~ task.name ~ " (role: " ~ task.assignedRoleId ~ ")");
    }

    // Return workflow with tasks
    return _workflowDetail(tenantId, wfId);
  }

  Json getWorkflow(UUID tenantId, UUID id) {
    return _workflowDetail(tenantId, id);
  }

  Json startWorkflow(UUID tenantId, UUID id) {
    CIAWorkflow wf;
    if (!_store.tryGetWorkflow(tenantId, id, wf))
      throw new CIANotFoundException("Workflow not found: " ~ id);
    if (wf.status != "planned")
      throw new CIAWorkflowStateException(
        "Workflow must be in 'planned' state to start. Current: " ~ wf.status);

    wf.status = "running";
    wf.startedAt = Clock.currTime();
    wf.updatedAt = Clock.currTime();
    _store.upsertWorkflow(wf);
    _appendLog(tenantId, id, "", "info", "Workflow started.");
    return _workflowDetail(tenantId, id);
  }

  Json completeWorkflow(UUID tenantId, UUID id) {
    CIAWorkflow wf;
    if (!_store.tryGetWorkflow(tenantId, id, wf))
      throw new CIANotFoundException("Workflow not found: " ~ id);
    if (wf.status != "running")
      throw new CIAWorkflowStateException(
        "Workflow must be in 'running' state to complete. Current: " ~ wf.status);

    wf.status = "completed";
    wf.finishedAt = Clock.currTime();
    wf.updatedAt = Clock.currTime();
    _store.upsertWorkflow(wf);
    _appendLog(tenantId, id, "", "info", "Workflow completed successfully.");
    return _workflowDetail(tenantId, id);
  }

  // -----------------------------------------------------------------------
  // Tasks
  // -----------------------------------------------------------------------
  Json listTasks(UUID tenantId, UUID workflowId) {
    _requireWorkflow(tenantId, workflowId);
    Json arr = Json.emptyArray;
    foreach (t; _store.listTasks(tenantId, workflowId))
      arr ~= t.toJson();
    return arr;
  }

  Json getTask(UUID tenantId, UUID workflowId, UUID taskId) {
    CIATask task;
    if (!_store.tryGetTask(tenantId, taskId, task) || task.workflowId != workflowId)
      throw new CIANotFoundException("Task not found: " ~ taskId);
    return task.toJson();
  }

  /// Assign a task to a role and/or user
  Json assignTask(UUID tenantId, UUID workflowId, UUID taskId, Json payload) {
    CIATask task;
    if (!_store.tryGetTask(tenantId, taskId, task) || task.workflowId != workflowId)
      throw new CIANotFoundException("Task not found: " ~ taskId);

    if ("role_id" in payload && payload["role_id"].get!string.length > 0)
      task.assignedRoleId = payload["role_id"].getString;
    if ("user_id" in payload && payload["user_id"].get!string.length > 0)
      task.assignedUserId = payload["user_id"].getString;
    task.updatedAt = Clock.currTime();
    _store.upsertTask(task);

    _appendLog(tenantId, workflowId, taskId, "info",
      "Task '" ~ task.name ~ "' assigned → role: " ~ task.assignedRoleId
        ~ ", user: " ~ task.assignedUserId);
    return task.toJson();
  }

  /// Progress a task status
  Json progressTask(UUID tenantId, UUID workflowId, UUID taskId, Json payload) {
    import std.algorithm : canFind;

    CIATask task;
    if (!_store.tryGetTask(tenantId, taskId, task) || task.workflowId != workflowId)
      throw new CIANotFoundException("Task not found: " ~ taskId);

    static immutable validStatuses = [
      "pending", "in-progress", "done", "skipped", "failed"
    ];
    auto newStatus = payload["status"].getString;
    if (!canFind(validStatuses, newStatus))
      throw new CIAValidationException("Invalid task status: " ~ newStatus);

    task.status = newStatus;
    task.updatedAt = Clock.currTime();
    _store.upsertTask(task);
    _appendLog(tenantId, workflowId, taskId, "info",
      "Task '" ~ task.name ~ "' status → " ~ newStatus);
    return task.toJson();
  }

  /// Trigger automated technical configuration for a task
  Json automateTask(UUID tenantId, UUID workflowId, UUID taskId) {
    CIATask task;
    if (!_store.tryGetTask(tenantId, taskId, task) || task.workflowId != workflowId)
      throw new CIANotFoundException("Task not found: " ~ taskId);
    if (!task.automated)
      throw new CIAValidationException("Task is not marked as automatable: " ~ taskId);

    // Simulate automation: mark as in-progress → done, record result
    _appendLog(tenantId, workflowId, taskId, "info",
      "Automation triggered for task: " ~ task.name);

    auto resultId = _store.nextId("auto");
    CIAAutomationResult result;
    result.tenantId = tenantId;
    result.workflowId = workflowId;
    result.taskId = taskId;
    result.id = resultId;
    result.targetSystemId = !task.context.isNull
      && "target_system_id" in task.context
      ? task.context["target_system_id"].get!string : "";
    result.status = "success";
    result.output = "Automated configuration applied successfully for task: " ~ task.name;
    result.startedAt = Clock.currTime();
    result.finishedAt = Clock.currTime();
    _store.upsertAutomationResult(result);

    // Auto-advance task to done
    task.status = "done";
    task.updatedAt = Clock.currTime();
    _store.upsertTask(task);

    _appendLog(tenantId, workflowId, taskId, "info",
      "Automation completed: " ~ result.output);

    return result.toJson();
  }

  // -----------------------------------------------------------------------
  // Parameters
  // -----------------------------------------------------------------------
  Json listParameters(UUID tenantId, UUID workflowId) {
    _requireWorkflow(tenantId, workflowId);
    Json arr = Json.emptyArray;
    foreach (p; _store.listParameters(workflowId))
      arr ~= p.toJson();
    return arr;
  }

  Json setParameter(UUID tenantId, UUID workflowId, Json payload) {
    _requireWorkflow(tenantId, workflowId);
    CIAParameter param;
    param.workflowId = workflowId;
    param.key = payload["key"].getString;
    param.value = payload["value"].getString;
    param.description = "description" in payload ? payload["description"].get!string : "";
    param.sensitive = "sensitive" in payload ? payload["sensitive"].get!bool : false;
    return _store.upsertParameter(param).toJson();
  }

  // -----------------------------------------------------------------------
  // Monitoring / Logs
  // -----------------------------------------------------------------------
  Json listLogs(UUID tenantId, UUID workflowId) {
    _requireWorkflow(tenantId, workflowId);
    Json arr = Json.emptyArray;
    foreach (l; _store.listLogs(tenantId, workflowId))
      arr ~= l.toJson();
    return arr;
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------
  private CIAWorkflow _requireWorkflow(UUID tenantId, UUID workflowId) {
    CIAWorkflow wf = new CIAWorkflow;
    if (!_store.tryGetWorkflow(tenantId, workflowId, wf))
      throw new CIANotFoundException("Workflow not found: " ~ workflowId);
    return wf;
  }

  private Json _workflowDetail(UUID tenantId, UUID wfId) {
    CIAWorkflow wf = new CIAWorkflow;
    if (!_store.tryGetWorkflow(tenantId, wfId, wf))
      throw new CIANotFoundException("Workflow not found: " ~ wfId);
    Json tasks = _store.listTasks(tenantId, wfId).map!(t => t.toJson()).array;

    return wf.toJson()
    .set("tasks", tasks);
  }

  private string _buildSystemList(UUID tenantId, string[] systemIds) {
    import std.array : join;

    string[] parts;
    foreach (sid; systemIds) {
      CIASystem sys = new CIASystem;
      parts ~= _store.tryGetSystem(tenantId, sid, sys)
        ? sys.name ~ " (" ~ sys.systemType ~ ")"
        : sid;
    }
    return parts.join(", ");
  }

  private void _appendLog(UUID tenantId, UUID workflowId, UUID taskId,
    string level, string message) {
    CIATaskLog log = new CIATaskLog;
    log.tenantId = tenantId;
    log.workflowId = workflowId;
    log.taskId = taskId;
    log.id = _store.nextId("log");
    log.message = message;
    log.level = level;
    log.timestamp = Clock.currTime();
    _store.upsertLog(log);
  }

  // -----------------------------------------------------------------------
  // Seed built-in roles and example scenarios
  // -----------------------------------------------------------------------
  private void _seedDefaultData() {
    // Default roles
    _store.upsertRole(CIARole("role-basis", "Basis Administrator", "SAP Basis admin responsible for system landscape configuration"));
    _store.upsertRole(CIARole("role-cloud", "Cloud Administrator", "Manages SAP BTP subaccounts, destinations and trust configurations"));
    _store.upsertRole(CIARole("role-iflow", "Integration Developer", "Designs and deploys Integration Suite iFlows and API artefacts"));
    _store.upsertRole(CIARole("role-security", "Security Administrator", "Manages certificates, credential stores, and OAuth clients"));
    _store.upsertRole(CIARole("role-qa", "Quality Assurance", "Validates integration connectivity and end-to-end scenario testing"));

    // Scenario 1: S/4HANA Cloud → SAP Integration Suite
    CIAScenario sc1 = new CIAScenario;
    sc1.id = "sc-s4hana-integration-suite";
    sc1.name = "S/4HANA Cloud → SAP Integration Suite";
    sc1.description = "Configure end-to-end integration between S/4HANA Cloud and SAP Integration Suite on BTP.";
    sc1.tags = ["cloud-to-cloud", "s4hana", "integration-suite"];
    sc1.requiredSystemTypes = ["s4hana-cloud", "integration-suite"];
    sc1.taskTemplates = [
      CIAScenarioTaskTemplate(1, "Verify System Landscape",
        "Confirm that all required systems are registered and reachable.",
        "1. Open the system landscape list.\n2. Confirm the S/4HANA Cloud tenant is registered.\n3. Confirm the Integration Suite tenant is registered.\n4. Mark step complete.\nSystems: {{systemList}}",
        "role-basis", false, ["pre-requisite"]),
      CIAScenarioTaskTemplate(2, "Create BTP Subaccount Destination",
        "Create a destination in the BTP subaccount pointing to S/4HANA Cloud.",
        "1. Log in to SAP BTP Cockpit.\n2. Navigate to the subaccount destinations.\n3. Create a new destination with type HTTP, pointing to the S/4HANA Cloud host.\n4. Configure authentication (OAuth2SAMLBearerAssertion or Basic).\n5. Save the destination.",
        "role-cloud", true, ["config", "automated"]),
      CIAScenarioTaskTemplate(3, "Configure OAuth Client in S/4HANA",
        "Register an OAuth client in S/4HANA Cloud for Integration Suite.",
        "1. In S/4HANA Cloud, open Communication Management.\n2. Create a Communication System for Integration Suite.\n3. Create a Communication Arrangement for the desired scenario.\n4. Note the OAuth client ID and secret.\n5. Store credentials in BTP Credential Store.",
        "role-basis", false, ["config"]),
      CIAScenarioTaskTemplate(4, "Deploy Integration iFlow",
        "Import and deploy the integration iFlow artefact in Integration Suite.",
        "1. Open SAP Integration Suite.\n2. Import the pre-built iFlow from the API Business Hub.\n3. Configure the sender and receiver channels.\n4. Deploy the iFlow to the runtime.\n5. Verify deployment status is 'Started'.",
        "role-iflow", true, ["config", "automated"]),
      CIAScenarioTaskTemplate(5, "Validate End-to-End Connectivity",
        "Trigger a test message and verify successful processing.",
        "1. Open the Integration Suite monitoring dashboard.\n2. Trigger a test message from S/4HANA.\n3. Confirm the message is processed without errors.\n4. Check S/4HANA outbound log for delivery confirmation.",
        "role-qa", false, ["validation"]),
    ];
    sc1.createdAt = Clock.currTime();
    sc1.updatedAt = Clock.currTime();
    _store.upsertScenario(sc1);

    // Scenario 2: S/4HANA On-Premises → SAP SuccessFactors
    CIAScenario sc2 = new CIAScenario;
    sc2.id = "sc-s4hana-onprem-successfactors";
    sc2.name = "S/4HANA On-Premises → SAP SuccessFactors";
    sc2.description = "Employee data integration from S/4HANA On-Premises to SAP SuccessFactors Employee Central.";
    sc2.tags = [
      "on-prem-to-cloud", "s4hana", "successfactors", "hr-integration"
    ];
    sc2.requiredSystemTypes = [
      "s4hana-on-prem", "successfactors", "integration-suite"
    ];
    sc2.taskTemplates = [
      CIAScenarioTaskTemplate(1, "Verify Network Connectivity",
        "Confirm that the on-premises S/4HANA system can reach the SAP BTP Cloud Connector.",
        "1. Validate that SAP Cloud Connector is installed and running.\n2. Open Cloud Connector admin UI.\n3. Verify the subaccount connection to BTP is active.\n4. Add the S/4HANA internal host as an exposed back-end resource.",
        "role-basis", false, ["pre-requisite"]),
      CIAScenarioTaskTemplate(2, "Configure Cloud Connector Mapping",
        "Map the on-premises S/4HANA host in Cloud Connector.",
        "1. In Cloud Connector, navigate to Cloud To On-Premise resources.\n2. Add the S/4HANA host with virtual and internal hostnames.\n3. Enable all required RFC and HTTP resources.\n4. Test the connection from BTP.",
        "role-cloud", true, ["config", "automated"]),
      CIAScenarioTaskTemplate(3, "Set Up SuccessFactors API Access",
        "Generate SuccessFactors API key and configure the OData service user.",
        "1. Log in to SuccessFactors Admin Center.\n2. Navigate to Manage OAuth2 Client Applications.\n3. Register a new OAuth2 client for Integration Suite.\n4. Note the API key, company ID, and token URL.\n5. Store in BTP Credential Store.",
        "role-security", false, ["config"]),
      CIAScenarioTaskTemplate(4, "Configure IDOC Outbound from S/4HANA",
        "Set up IDoc partner profile for outbound Employee messages.",
        "1. In S/4HANA, run transaction WE20.\n2. Create a partner profile for the Integration Suite receiver.\n3. Configure outbound parameters for message type HRMD_A.\n4. Assign the port used by Cloud Connector.\n5. Test with transaction WE19.",
        "role-basis", false, ["config"]),
      CIAScenarioTaskTemplate(5, "Deploy and Configure HCM iFlow",
        "Import, configure, and deploy the HCM integration iFlow.",
        "1. Open SAP Integration Suite.\n2. Import the HCM Integration iFlow package.\n3. Configure sender channel (IDoc adapter) with Cloud Connector proxy.\n4. Configure receiver channel (SuccessFactors OData adapter).\n5. Set employee mapping parameters.\n6. Deploy the iFlow.",
        "role-iflow", true, ["config", "automated"]),
      CIAScenarioTaskTemplate(6, "End-to-End Integration Test",
        "Run a test employee record and verify it appears in SuccessFactors.",
        "1. In S/4HANA, create or modify a test employee.\n2. Trigger the IDoc outbound.\n3. Monitor the iFlow in Integration Suite for successful processing.\n4. Verify the employee record in SuccessFactors Employee Central.\n5. Document the test result.",
        "role-qa", false, ["validation"]),
    ];
    sc2.createdAt = Clock.currTime();
    sc2.updatedAt = Clock.currTime();
    _store.upsertScenario(sc2);

    // Scenario 3: SAP Ariba Network Integration
    CIAScenario sc3 = new CIAScenario;
    sc3.id = "sc-s4hana-ariba-procurement";
    sc3.name = "S/4HANA Cloud → SAP Ariba (Procurement)";
    sc3.description = "Configure purchase order integration from S/4HANA Cloud to SAP Ariba Network.";
    sc3.tags = ["cloud-to-cloud", "procurement", "ariba"];
    sc3.requiredSystemTypes = ["s4hana-cloud", "ariba", "integration-suite"];
    sc3.taskTemplates = [
      CIAScenarioTaskTemplate(1, "Register Ariba Network Account",
        "Confirm Ariba Network buyer account and API credentials are available.",
        "1. Log in to SAP Ariba Network as administrator.\n2. Navigate to Administration → Integration.\n3. Note the Ariba Network ID (ANID) and shared secret.\n4. Enable the cXML Integration.",
        "role-cloud", false, ["pre-requisite"]),
      CIAScenarioTaskTemplate(2, "Configure Ariba Integration in BTP",
        "Set up the Ariba integration scenario in SAP BTP Integration Suite.",
        "1. Open SAP Integration Suite Package for Ariba.\n2. Import the Purchase Order integration package.\n3. Configure Ariba sender adapter with ANID and shared secret.\n4. Configure S/4HANA receiver channel.\n5. Deploy the iFlow.",
        "role-iflow", true, ["config", "automated"]),
      CIAScenarioTaskTemplate(3, "Validate Purchase Order Flow",
        "Create a test purchase order and verify Ariba receipt.",
        "1. In S/4HANA Cloud, create a test purchase order for an Ariba-connected vendor.\n2. Confirm the PO is sent to Ariba Network.\n3. Log in to Ariba Network and verify PO receipt.\n4. Confirm order status is 'New' in Ariba.",
        "role-qa", false, ["validation"]),
    ];
    sc3.createdAt = Clock.currTime();
    sc3.updatedAt = Clock.currTime();
    _store.upsertScenario(sc3);
  }
}
