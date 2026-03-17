module uim.sap.bas.service;

import uim.sap.bas;

mixin(ShowModule!());

@safe:


class BASService : SAPService {
  mixin(SAPServiceTemplate!BASService);

  private BASStore _store;
  private BASScenario[] _scenarios;
  private BASTemplate[] _templates;

  this(BASConfig config) {
    super(config);

    _store = new BASStore;
    seedReferenceContent();
  }

  Json health() const {
    Json healthInfo = super.health();
    healthInfo["default_region"] = _config.defaultRegion;
    healthInfo["scenarios"] = cast(long)_scenarios.length;
    return healthInfo;
  }

  Json listScenarios(string tenantId) {
    validateTenant(tenantId);

    Json scenarios = _scenarios.map!(scenario => scenario.toJson()).array.toJson;
    Json payload = Json.emptyObject;
    payload["scenarios"] = scenarios;
    payload["count"] = cast(long)scenarios.length;
    return payload;
  }

  Json listTemplates(string tenantId, string scenarioId = "") {
    validateTenant(tenantId);

    Json templates = Json.emptyArray;
    foreach (templateValue; _templates) {
      if (scenarioId.length > 0 && templateValue.scenarioId != scenarioId)
        continue;
      templates ~= templateValue.toJson();
    }

    Json payload = Json.emptyObject;
    payload["templates"] = templates;
    payload["count"] = cast(long)templates.length;
    return payload;
  }

  Json createWorkspace(string tenantId, Json data) {
    validateTenant(tenantId);

    auto scenarioid = requiredUUID(body, "scenario_id");
    if (!hasScenario(scenarioId))
      throw new BASValidationException("Unsupported scenario_id");

    auto now = Clock.currTime();
    BASWorkspace workspace;
    workspace.tenantId = UUID(tenantId);
    workspace.workspaceId = optionalString(body, "workspace_id", "ws-" ~ to!string(now.stdTime));
    workspace.name = requiredString(body, "name");
    workspace.scenarioId = scenarioId;
    workspace.region = optionalString(body, "region", _config.defaultRegion);
    workspace.status = "RUNNING";
    workspace.accessUrl = optionalString(body, "access_url", "https://bas.example.local/" ~ tenantId ~ "/" ~ workspace
        .workspaceId);
    workspace.terminalEnabled = optionalBoolean(data, "terminal_enabled", true);
    workspace.debugEnabled = optionalBoolean(data, "debug_enabled", true);
    workspace.createdAt = now;
    workspace.updatedAt = now;

    auto saved = _store.upsertWorkspace(workspace);

    Json payload = Json.emptyObject;
    payload["message"] = "Workspace created";
    payload["workspace"] = saved.toJson();
    return payload;
  }

  Json listWorkspaces(string tenantId) {
    validateTenant(tenantId);
    Json workspaces = Json.emptyArray;
    foreach (workspace; _store.listWorkspaces(tenantId))
      workspaces ~= workspace.toJson();

    Json payload = Json.emptyObject;
    payload["workspaces"] = workspaces;
    payload["count"] = cast(long)workspaces.length;
    return payload;
  }

  Json runWizard(string tenantId, string workspaceId, Json data) {
    auto workspace = requireWorkspace(tenantId, workspaceId);
    auto templateid = requiredUUID(body, "template_id");
    if (!hasTemplate(templateId, workspace.scenarioId)) {
      throw new BASValidationException("Template is not compatible with workspace scenario");
    }

    auto now = Clock.currTime();
    BASWizardRun run;
    run.tenantId = UUID(tenantId);
    run.workspaceId = workspaceId;
    run.runId = "wiz-" ~ to!string(now.stdTime);
    run.templateId = templateId;
    run.status = "SUCCESS";
    run.input = readObject(body, "input");
    run.output = Json.emptyObject;
    run.output["generated_project"] = "generated-" ~ templateId;
    run.output["graphical_editor_ready"] = true;
    run.output["quick_deploy_suggested"] = true;
    run.startedAt = now;
    run.finishedAt = Clock.currTime();

    auto saved = _store.upsertWizardRun(run);

    Json payload = Json.emptyObject;
    payload["message"] = "Wizard executed";
    payload["wizard_run"] = saved.toJson();
    return payload;
  }

  Json listWizardRuns(string tenantId, string workspaceId) {
    requireWorkspace(tenantId, workspaceId);

    Json runs = Json.emptyArray;
    foreach (run; _store.listWizardRuns(tenantId, workspaceId))
      runs ~= run.toJson();

    Json payload = Json.emptyObject;
    payload["wizard_runs"] = runs;
    payload["count"] = cast(long)runs.length;
    return payload;
  }

  Json createTerminalSession(string tenantId, string workspaceId, Json data) {
    auto workspace = requireWorkspace(tenantId, workspaceId);
    if (!workspace.terminalEnabled)
      throw new BASValidationException("Terminal access is disabled for workspace");

    auto now = Clock.currTime();
    BASTerminalSession session;
    session.tenantId = UUID(tenantId);
    session.workspaceId = workspaceId;
    session.sessionId = "term-" ~ to!string(now.stdTime);
    session.shell = optionalString(body, "shell", "bash");
    session.status = "OPEN";
    session.createdAt = now;

    auto saved = _store.upsertTerminalSession(session);

    Json payload = Json.emptyObject;
    payload["message"] = "Terminal session opened";
    payload["session"] = saved.toJson();
    return payload;
  }

  Json listTerminalSessions(string tenantId, string workspaceId) {
    requireWorkspace(tenantId, workspaceId);

    Json sessions = Json.emptyArray;
    foreach (session; _store.listTerminalSessions(tenantId, workspaceId))
      sessions ~= session.toJson();

    Json payload = Json.emptyObject;
    payload["sessions"] = sessions;
    payload["count"] = cast(long)sessions.length;
    return payload;
  }

  Json runLocalTest(string tenantId, string workspaceId, Json data) {
    auto workspace = requireWorkspace(tenantId, workspaceId);
    if (!workspace.debugEnabled)
      throw new BASValidationException("Debug mode is disabled for workspace");

    Json payload = Json.emptyObject;
    payload["message"] = "Local test and debug run completed";
    payload["workspace_id"] = workspaceId;
    payload["test_suite"] = optionalString(body, "test_suite", "default");
    payload["result"] = "PASS";
    payload["duration_ms"] = 820;
    return payload;
  }

  Json createDeployment(string tenantId, string workspaceId, Json data) {
    requireWorkspace(tenantId, workspaceId);

    auto now = Clock.currTime();
    BASDeployment deployment;
    deployment.tenantId = UUID(tenantId);
    deployment.workspaceId = workspaceId;
    deployment.deploymentId = optionalString(body, "deployment_id", "dep-" ~ to!string(now.stdTime));
    deployment.target = optionalString(body, "target", "sap-btp-cloud-foundry");
    deployment.mode = optionalString(body, "mode", "quick-deploy");
    deployment.status = "QUEUED";
    deployment.createdAt = now;

    auto saved = _store.upsertDeployment(deployment);

    Json payload = Json.emptyObject;
    payload["message"] = "Deployment queued";
    payload["deployment"] = saved.toJson();
    return payload;
  }

  Json listDeployments(string tenantId, string workspaceId) {
    requireWorkspace(tenantId, workspaceId);

    Json deployments = Json.emptyArray;
    foreach (deployment; _store.listDeployments(tenantId, workspaceId))
      deployments ~= deployment.toJson();

    Json payload = Json.emptyObject;
    payload["deployments"] = deployments;
    payload["count"] = cast(long)deployments.length;
    return payload;
  }

  Json availability() const {
    Json payload = Json.emptyObject;

    Json regions = Json.emptyArray;
    foreach (region; _config.regions)
      regions ~= region;

    Json hyperscalers = Json.emptyArray;
    foreach (provider; _config.hyperscalers)
      hyperscalers ~= provider;

    payload["multi_cloud"] = true;
    payload["browser_access"] = true;
    payload["regions"] = regions;
    payload["hyperscalers"] = hyperscalers;
    payload["desktop_like_experience"] = true;
    return payload;
  }

  private void seedReferenceContent() {
    BASScenario fiori;
    fiori.scenarioId = "fiori";
    fiori.name = "Fiori";
    fiori.description = "Build Fiori applications with guided tooling and templates.";
    fiori.supportedSolutions = ["SAPUI5", "Fiori elements", "CAP"];
    _scenarios ~= fiori;

    BASScenario s4;
    s4.scenarioId = "s4hana-extension";
    s4.name = "S/4HANA Extension";
    s4.description = "Develop side-by-side and key-user extension apps for S/4HANA.";
    s4.supportedSolutions = ["RAP", "CAP", "ABAP Environment"];
    _scenarios ~= s4;

    BASScenario workflow;
    workflow.scenarioId = "workflow";
    workflow.name = "Workflow";
    workflow.description = "Create process automation and approval workflow applications.";
    workflow.supportedSolutions = [
      "Build Process Automation", "Workflow Service"
    ];
    _scenarios ~= workflow;

    BASTemplate fioriTemplate;
    fioriTemplate.templateId = "tpl-fiori-elements";
    fioriTemplate.scenarioId = "fiori";
    fioriTemplate.name = "Fiori Elements List Report";
    fioriTemplate.language = "TypeScript";
    fioriTemplate.graphicalEditor = true;
    _templates ~= fioriTemplate;

    BASTemplate s4Template;
    s4Template.templateId = "tpl-s4-cap-extension";
    s4Template.scenarioId = "s4hana-extension";
    s4Template.name = "CAP Service Extension";
    s4Template.language = "Node.js";
    s4Template.graphicalEditor = false;
    _templates ~= s4Template;

    BASTemplate workflowTemplate;
    workflowTemplate.templateId = "tpl-workflow-approval";
    workflowTemplate.scenarioId = "workflow";
    workflowTemplate.name = "Workflow Approval App";
    workflowTemplate.language = "JavaScript";
    workflowTemplate.graphicalEditor = true;
    _templates ~= workflowTemplate;
  }

  private BASWorkspace requireWorkspace(string tenantId, string workspaceId) {
    validateTenant(tenantId);
    if (workspaceId.length == 0)
      throw new BASValidationException("workspace_id is required");

    auto workspace = _store.getWorkspace(tenantId, workspaceId);
    if (workspace.isNull)
      throw new BASNotFoundException("Workspace not found");
    return workspace.get;
  }

  private bool hasScenario(string scenarioId) const {
    return _scenarios.any!(scenario => scenario.scenarioId == scenarioId);
  }

  private bool hasTemplate(string templateId, string scenarioId) const {
    foreach (templateValue; _templates) {
      if (templateValue.templateId != templateId)
        continue;

      return templateValue.scenarioId == scenarioId;
    }
    return false;
  }

  private void validateTenant(string tenantId) const {
    if (tenantId.length == 0)
      throw new BASValidationException("tenant_id is required");
  }

  private string requiredString(Json data, string key) const {
    if (!(key in data) || !data[key].isString || data[key].get!string.length == 0) {
      throw new BASValidationException(key ~ " is required");
    }
    return data[key].get!string;
  }

  private Json readObject(Json data, string key) const {
    if (!(key in data) || data[key].isNull)
      return Json.emptyObject;
    if (!data[key].isObject)
      throw new BASValidationException(key ~ " must be an object");
    return data[key];
  }
}
