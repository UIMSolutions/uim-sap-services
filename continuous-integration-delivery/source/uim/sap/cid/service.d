module uim.sap.cid.service;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDService – business logic for Continuous Integration and Delivery
// ---------------------------------------------------------------------------
class CIDService : SAPService {
  mixin(SAPServiceTemplate!CIDService);

  private CIDStore _store;

  this(CIDConfig config) {
    super(config);

    _store = new CIDStore;
  }

  // -----------------------------------------------------------------------
  // Health / readiness
  // -----------------------------------------------------------------------
  override Json health() {
    return super.health()
    .set("runtime", _config.runtime)
    .set("multitenancy", true)
    .set("domain", "continuous-integration-delivery");
  }

  // -----------------------------------------------------------------------
  // Dashboard HTML
  // -----------------------------------------------------------------------
  string dashboardHtml() const {
    return import("dashboard.html");
  }

  // =======================================================================
  // REPOSITORIES
  // =======================================================================
  Json listRepositories(UUID tenantId) {
    return _store.listRepos(tenantId).map!(r => r.toJson()).array.toJson();
  }

  Json createRepository(UUID tenantId, Json payload) {
    if (!("clone_url" in payload) || payload["clone_url"].get!string.length == 0)
      throw new CIDValidationException("clone_url is required");

    CIDRepository r;
    r.tenantId = tenantId;
    r.repoId = "repo_id" in payload ? payload["repo_id"].get!string : createId();
    r.name = jstr(payload, "name", r.repoId);
    r.description = jstr(payload, "description");
    r.cloneUrl = payload["clone_url"].get!string;
    r.defaultBranch = jstr(payload, "default_branch", "main");
    r.credentialId = jstr(payload, "credential_id");
    r.provider = jstr(payload, "provider", "github");
    r.webhookSecret = jstr(payload, "webhook_secret");
    r.active = jbool(payload, "active", true);
    r.createdAt = Clock.currTime();
    r.updatedAt = r.createdAt;

    // Validate credential reference if given
    if (r.credentialId.length > 0) {
      CIDCredential cred;
      if (!_store.tryGetCredential(tenantId, r.credentialId, cred))
        throw new CIDNotFoundException("Credential", r.credentialId);
    }

    _store.upsertRepo(r);
    _appendLog(tenantId, "", "", "info", "Repository connected: " ~ r.name ~ " (" ~ r.cloneUrl ~ ")");
    return r.toJson();
  }

  Json getRepository(UUID tenantId, string repoId) {
    CIDRepository r;
    if (!_store.tryGetRepo(tenantId, repoId, r))
      throw new CIDNotFoundException("Repository", repoId);
    auto j = r.toJson();
    // Embed pipelines using this repository
    Json pipelines = Json.emptyArray;
    foreach (p; _store.listPipelines(tenantId))
      if (p.repositoryId == repoId)
        pipelines ~= p.toJson();
    j["pipelines"] = pipelines;
    return j;
  }

  Json removeRepository(UUID tenantId, string repoId) {
    if (!_store.removeRepo(tenantId, repoId))
      throw new CIDNotFoundException("Repository", repoId);
    _appendLog(tenantId, "", "", "info", "Repository removed: " ~ repoId);
    
    return Json.emptyObject
      .set("deleted", repoId);
  }

  // =======================================================================
  // CREDENTIALS
  // =======================================================================
  Json listCredentials(UUID tenantId) {
    return _store.listCredentials(tenantId).map!(c => c.toJson()).array.toJson();
  }

  Json createCredential(UUID tenantId, Json payload) {
    if (!("name" in payload) || payload["name"].get!string.length == 0)
      throw new CIDValidationException("Credential name is required");

    CIDCredential c;
    c.tenantId = tenantId;
    c.credentialId = "credential_id" in payload ? payload["credential_id"].get!string : createId();
    c.name = payload["name"].get!string;
    c.description = jstr(payload, "description");
    c.credentialType = jstr(payload, "credential_type", "token");
    c.username = jstr(payload, "username");
    c.token = jstr(payload, "token");
    c.sshKey = jstr(payload, "ssh_key");
    c.createdAt = Clock.currTime();
    c.updatedAt = c.createdAt;

    // Validate that at least one secret is provided
    if (c.token.length == 0 && c.sshKey.length == 0 && c.username.length == 0)
      throw new CIDValidationException(
        "At least one of token, ssh_key, or username must be provided");

    _store.upsertCredential(c);
    _appendLog(tenantId, "", "", "info", "Credential created: " ~ c.name ~ " (" ~ c.credentialType ~ ")");
    return c.toJson();
  }

  Json removeCredential(UUID tenantId, string credId) {
    if (!_store.removeCredential(tenantId, credId))
      throw new CIDNotFoundException("Credential", credId);
    _appendLog(tenantId, "", "", "info", "Credential removed: " ~ credId);

    return Json.emptyObject
      .set("deleted", credId);
  }

  // =======================================================================
  // PIPELINES
  // =======================================================================
  Json listPipelines(UUID tenantId) {
    return _store.listPipelines(tenantId).map!(p => p.toJson()).array.toJson();
  }

  Json createPipeline(UUID tenantId, Json payload) {
    if (!("name" in payload) || payload["name"].get!string.length == 0)
      throw new CIDValidationException("Pipeline name is required");

    auto repoId = jstr(payload, "repository_id");
    if (repoId.length > 0)
      _requireRepo(tenantId, repoId);

    CIDPipeline p;
    p.tenantId = tenantId;
    p.pipelineId = "pipeline_id" in payload ? payload["pipeline_id"].get!string : createId();
    p.name = payload["name"].get!string;
    p.description = jstr(payload, "description");
    p.repositoryId = repoId;
    p.branch = jstr(payload, "branch", "main");
    p.pipelineType = jstr(payload, "pipeline_type", "custom");
    p.deployTarget = jstr(payload, "deploy_target", "cloud-foundry");
    p.deployEndpoint = jstr(payload, "deploy_endpoint");
    p.deployCredentialId = jstr(payload, "deploy_credential_id");
    p.autoTrigger = jbool(payload, "auto_trigger", false);
    p.active = jbool(payload, "active", true);
    p.createdAt = Clock.currTime();
    p.updatedAt = p.createdAt;

    // Parse stages from payload or use defaults based on pipeline type
    if ("stages" in payload && payload["stages"].isArray) {
      foreach (s; payload["stages"].toArray)
        p.stages ~= s.get!string;
    } else {
      p.stages = defaultStages(p.pipelineType);
    }

    _store.upsertPipeline(p);
    _appendLog(tenantId, "", "", "info",
      "Pipeline created: " ~ p.name ~ " [" ~ p.pipelineType ~ "]");
    return p.toJson();
  }

  Json getPipeline(UUID tenantId, string pipelineId) {
    CIDPipeline p;
    if (!_store.tryGetPipeline(tenantId, pipelineId, p))
      throw new CIDNotFoundException("Pipeline", pipelineId);
    auto j = p.toJson();
    // Embed recent builds
    Json builds = Json.emptyArray;
    foreach (b; _store.listBuildsByPipeline(tenantId, pipelineId))
      builds ~= b.toJson();
    j["builds"] = builds;
    return j;
  }

  Json removePipeline(UUID tenantId, string pipelineId) {
    if (!_store.removePipeline(tenantId, pipelineId))
      throw new CIDNotFoundException("Pipeline", pipelineId);
    _appendLog(tenantId, "", "", "info", "Pipeline removed: " ~ pipelineId);
    
    return Json.emptyObject
      .set("deleted", pipelineId);
  }

  // =======================================================================
  // BUILDS  (pipeline runs)
  // =======================================================================
  Json listBuilds(UUID tenantId) {
    return _store.listBuilds(tenantId).map!(b => b.toJson()).array.toJson();
  }

  /// Trigger a new build for the given pipeline
  Json triggerBuild(UUID tenantId, string pipelineId, Json payload) {
    CIDPipeline p;
    if (!_store.tryGetPipeline(tenantId, pipelineId, p))
      throw new CIDNotFoundException("Pipeline", pipelineId);

    if (!p.active)
      throw new CIDPipelineException("Pipeline is inactive: " ~ pipelineId);

    // Check no build is already running for this pipeline
    foreach (b; _store.listBuildsByPipeline(tenantId, pipelineId))
      if (b.status == "running" || b.status == "pending")
        throw new CIDPipelineException(
          "Build already in progress for pipeline " ~ pipelineId
            ~ " (build " ~ b.buildId ~ ")");

    auto now = Clock.currTime();
    int nextNumber = _store.maxBuildNumber(tenantId, pipelineId) + 1;

    CIDBuild build;
    build.tenantId = tenantId;
    build.buildId = _store.nextId("build");
    build.pipelineId = pipelineId;
    build.buildNumber = nextNumber;
    build.commitHash = jstr(payload, "commit_hash", "HEAD");
    build.branch = jstr(payload, "branch", p.branch);
    build.status = "pending";
    build.triggeredBy = jstr(payload, "triggered_by", "manual");
    build.createdAt = now;
    build.startedAt = now;
    _store.upsertBuild(build);

    _appendLog(tenantId, build.buildId, "", "info",
      "Build #" ~ to!string(nextNumber) ~ " triggered for pipeline " ~ p.name);

    // Create stages based on pipeline config
    _createStages(build.buildId, p.stages);

    // Simulate execution: run through stages
    _simulateBuild(tenantId, build.buildId, p);

    return _buildDetail(tenantId, build.buildId);
  }

  Json getBuild(UUID tenantId, string buildId) {
    return _buildDetail(tenantId, buildId);
  }

  /// Abort a running or pending build
  Json abortBuild(UUID tenantId, string buildId) {
    CIDBuild build;
    if (!_store.tryGetBuild(tenantId, buildId, build))
      throw new CIDNotFoundException("Build", buildId);

    if (build.status != "running" && build.status != "pending")
      throw new CIDPipelineException(
        "Only running or pending builds can be aborted (current: " ~ build.status ~ ")");

    build.status = "aborted";
    build.finishedAt = Clock.currTime();
    _store.upsertBuild(build);

    // Mark any running/pending stages as skipped
    foreach (stage; _store.listStages(buildId)) {
      if (stage.status == "running" || stage.status == "pending") {
        stage.status = "skipped";
        stage.finishedAt = Clock.currTime();
        _store.upsertStage(stage);
      }
    }

    _appendLog(tenantId, buildId, "", "warning", "Build aborted");
    return _buildDetail(tenantId, buildId);
  }

  Json listStages(UUID tenantId, string buildId) {
    _requireBuild(tenantId, buildId);
    Json arr = Json.emptyArray;
    foreach (s; _store.listStages(buildId))
      arr ~= s.toJson();
    return arr;
  }

  Json listBuildLogs(UUID tenantId, string buildId) {
    _requireBuild(tenantId, buildId);
    Json arr = Json.emptyArray;
    foreach (l; _store.listLogs(tenantId, buildId))
      arr ~= l.toJson();
    return arr;
  }

  // =======================================================================
  // Private helpers
  // =======================================================================

  /// Default stages per pipeline type
  private static string[] defaultStages(string pipelineType) {
    switch (pipelineType) {
    case "sap-cloud-sdk":
      return ["build", "test", "lint", "deploy"];
    case "sap-fiori":
      return ["build", "test", "deploy"];
    case "sap-integration":
      return ["build", "test", "deploy"];
    case "sap-abap":
      return ["build", "test"];
    default:
      return ["build", "test", "deploy"];
    }
  }

  /// Create stage records for a build
  private void _createStages(string buildId, string[] stageNames) {
    int ordinal = 1;
    foreach (name; stageNames) {
      CIDBuildStage stage;
      stage.buildId = buildId;
      stage.stageId = _store.nextId("stage");
      stage.name = name;
      stage.ordinal = ordinal++;
      stage.status = "pending";
      _store.upsertStage(stage);
    }
  }

  /// Simulate running through every stage of a build
  private void _simulateBuild(UUID tenantId, string buildId, CIDPipeline pipeline) {
    CIDBuild build;
    if (!_store.tryGetBuild(tenantId, buildId, build))
      return;

    build.status = "running";
    build.startedAt = Clock.currTime();
    _store.upsertBuild(build);

    auto stages = _store.listStages(buildId);
    bool failed = false;
    foreach (ref stage; stages) {
      if (failed) {
        stage.status = "skipped";
        _store.upsertStage(stage);
        continue;
      }

      stage.status = "running";
      stage.startedAt = Clock.currTime();
      _store.upsertStage(stage);

      _appendLog(tenantId, buildId, stage.stageId, "info",
        "Stage '" ~ stage.name ~ "' started");

      // Simulate stage execution (always succeeds in this mock)
      stage.status = "success";
      stage.finishedAt = Clock.currTime();
      stage.durationSecs = 1;
      _store.upsertStage(stage);

      _appendLog(tenantId, buildId, stage.stageId, "info",
        "Stage '" ~ stage.name ~ "' completed successfully");
    }

    // Finalize build
    build.status = failed ? "failure" : "success";
    build.finishedAt = Clock.currTime();
    build.durationSecs = cast(long)(stages.length); // simplified
    _store.upsertBuild(build);

    _appendLog(tenantId, buildId, "", "info",
      "Build #" ~ to!string(build.buildNumber) ~ " finished: " ~ build.status);
  }

  private CIDRepository _requireRepo(UUID tenantId, string repoId) {
    CIDRepository r;
    if (!_store.tryGetRepo(tenantId, repoId, r))
      throw new CIDNotFoundException("Repository", repoId);
    return r;
  }

  private CIDBuild _requireBuild(UUID tenantId, string buildId) {
    CIDBuild b;
    if (!_store.tryGetBuild(tenantId, buildId, b))
      throw new CIDNotFoundException("Build", buildId);
    return b;
  }

  private Json _buildDetail(UUID tenantId, string buildId) {
    CIDBuild build;
    if (!_store.tryGetBuild(tenantId, buildId, build))
      throw new CIDNotFoundException("Build", buildId);
    auto j = build.toJson();
    // Embed stages
    Json stages = Json.emptyArray;
    foreach (s; _store.listStages(buildId))
      stages ~= s.toJson();
    j["stages"] = stages;
    return j;
  }

  private void _appendLog(UUID tenantId, string buildId, string stageId,
    string level, string message) {
    CIDBuildLog log;
    log.tenantId = tenantId;
    log.logId = _store.nextId("log");
    log.buildId = buildId;
    log.stageId = stageId;
    log.level = level;
    log.message = message;
    log.timestamp = Clock.currTime();
    _store.upsertLog(log);
  }

  // -----------------------------------------------------------------------
  // JSON helpers
  // -----------------------------------------------------------------------
  private static string jstr(Json j, string key, string fallback = "") {
    if (key in j && j[key].isString)
      return j[key].get!string;
    return fallback;
  }

  private static bool jbool(Json j, string key, bool fallback = false) {
    if (key in j) {
      auto v = j[key];
      if (v.isBoolean)
        return v.get!bool;
      if (v.type == Json.Type.true_)
        return true;
      if (v.type == Json.Type.false_)
        return false;
    }
    return fallback;
  }
}
