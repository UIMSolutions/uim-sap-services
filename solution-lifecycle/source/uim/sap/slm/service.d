module uim.sap.slm.service;

import std.algorithm : canFind;
import std.array : array;
import std.conv : to;
import std.datetime : Clock, SysTime;
import std.string : toLower;

import vibe.data.json : Json;

import uim.sap.slm.config;
import uim.sap.slm.exceptions;
import uim.sap.slm.models;
import uim.sap.slm.store;

// ---------------------------------------------------------------------------
// SLMService – business logic for Solution Lifecycle Management
// ---------------------------------------------------------------------------
class SLMService : SAPService {
  mixin(SAPServiceTemplate!SLMService);

  private SLMStore _store;

  this(SLMConfig config) {
    super(config);

    _store = new SLMStore;
  }

  // -----------------------------------------------------------------------
  // Health / readiness
  // -----------------------------------------------------------------------
  Json health() const {
    Json healthInfo = super.health();
    healthInfo["runtime"] = _config.runtime;
    healthInfo["multitenancy"] = true;
    healthInfo["domain"] = "solution-lifecycle";
    return healthInfo;
  }

  // -----------------------------------------------------------------------
  // Dashboard HTML
  // -----------------------------------------------------------------------
  string dashboardHtml() const {
    return import("dashboard.html");
  }

  // -----------------------------------------------------------------------
  // SOLUTIONS – Deploy, Update, Monitor, Delete
  // -----------------------------------------------------------------------

  /// List all solutions in a tenant
  Json listSolutions(UUID tenantId) {
    return _store.listSolutions(tenantId).map!(s => s.toJson()).array.toJson;
  }

  /// Deploy a new solution via MTA archive
  Json deploySolution(UUID tenantId, Json payload) {
    SLMSolution sol;
    sol.tenantId = tenantId;
    sol.solutionId = jstr(payload, "solution_id");
    if (sol.solutionId.length == 0)
      sol.solutionId = _store.nextId("sol");
    sol.name = payload["name"].get!string;
    sol.description = jstr(payload, "description");
    sol.mtaId = payload["mta_id"].get!string;
    sol.mtaVersion = jstr(payload, "mta_version", "1.0.0");
    sol.status = "deploying";
    sol.globalAccountId = jstr(payload, "global_account_id");
    sol.subaccountId = jstr(payload, "subaccount_id");
    sol.spaceId = jstr(payload, "space_id");
    sol.orgId = jstr(payload, "org_id");
    sol.multitenant = jbool(payload, "multitenant", false);
    sol.deployedBy = jstr(payload, "deployed_by", "api");
    sol.createdAt = Clock.currTime();
    sol.updatedAt = sol.createdAt;
    _store.upsertSolution(sol);

    // Create a deployment record
    SLMDeployment dep;
    dep.tenantId = tenantId;
    dep.deploymentId = _store.nextId("dep");
    dep.solutionId = sol.solutionId;
    dep.mtaArchiveRef = jstr(payload, "mta_archive_ref");
    dep.mtaVersion = sol.mtaVersion;
    dep.action = "deploy";
    dep.status = "running";
    dep.triggeredBy = sol.deployedBy;
    dep.startedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    // Simulate: create default components from MTA descriptor
    _createDefaultComponents(sol.solutionId, payload);

    // Simulate deployment success
    dep.status = "succeeded";
    dep.finishedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    sol.status = "deployed";
    sol.updatedAt = Clock.currTime();
    _store.upsertSolution(sol);

    _appendLog(tenantId, sol.solutionId, dep.deploymentId, "deployed", "info",
      "Solution '" ~ sol.name ~ "' deployed (MTA: " ~ sol.mtaId ~ " v" ~ sol.mtaVersion ~ ")");

    return _solutionDetail(tenantId, sol.solutionId);
  }

  /// Get full detail for a single solution
  Json getSolution(UUID tenantId, string solutionId) {
    return _solutionDetail(tenantId, solutionId);
  }

  /// Update an existing solution (new MTA version)
  Json updateSolution(UUID tenantId, string solutionId, Json payload) {
    SLMSolution sol;
    if (!_store.tryGetSolution(tenantId, solutionId, sol))
      throw new SLMNotFoundException("Solution", solutionId);
    if (sol.status != "deployed")
      throw new SLMSolutionStateException(
        "Solution must be in 'deployed' status to update (current: " ~ sol.status ~ ")");

    auto newVersion = jstr(payload, "mta_version", sol.mtaVersion);
    auto archiveRef = jstr(payload, "mta_archive_ref");

    sol.status = "updating";
    sol.updatedAt = Clock.currTime();
    _store.upsertSolution(sol);

    SLMDeployment dep;
    dep.tenantId = tenantId;
    dep.deploymentId = _store.nextId("dep");
    dep.solutionId = solutionId;
    dep.mtaArchiveRef = archiveRef;
    dep.mtaVersion = newVersion;
    dep.action = "update";
    dep.status = "running";
    dep.triggeredBy = jstr(payload, "triggered_by", "api");
    dep.startedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    // Simulate update: refresh components
    _store.removeComponentsForSolution(solutionId);
    _createDefaultComponents(solutionId, payload);

    dep.status = "succeeded";
    dep.finishedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    sol.mtaVersion = newVersion;
    sol.status = "deployed";
    sol.updatedAt = Clock.currTime();
    _store.upsertSolution(sol);

    _appendLog(tenantId, solutionId, dep.deploymentId, "updated", "info",
      "Solution updated to v" ~ newVersion);

    return _solutionDetail(tenantId, solutionId);
  }

  /// Delete a solution
  Json deleteSolution(UUID tenantId, string solutionId) {
    SLMSolution sol;
    if (!_store.tryGetSolution(tenantId, solutionId, sol))
      throw new SLMNotFoundException("Solution", solutionId);

    sol.status = "deleting";
    sol.updatedAt = Clock.currTime();
    _store.upsertSolution(sol);

    SLMDeployment dep;
    dep.tenantId = tenantId;
    dep.deploymentId = _store.nextId("dep");
    dep.solutionId = solutionId;
    dep.action = "delete";
    dep.status = "running";
    dep.triggeredBy = "api";
    dep.startedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    // Remove components
    _store.removeComponentsForSolution(solutionId);

    dep.status = "succeeded";
    dep.finishedAt = Clock.currTime();
    _store.upsertDeployment(dep);

    sol.status = "deleted";
    sol.updatedAt = Clock.currTime();
    _store.upsertSolution(sol);

    _appendLog(tenantId, solutionId, dep.deploymentId, "deleted", "info",
      "Solution '" ~ sol.name ~ "' deleted");

    return sol.toJson();
  }

  // -----------------------------------------------------------------------
  // COMPONENTS – Monitor individual parts of a solution
  // -----------------------------------------------------------------------

  Json listComponents(UUID tenantId, string solutionId) {
    _requireSolution(tenantId, solutionId);
    Json arr = Json.emptyArray;
    foreach (c; _store.listComponents(solutionId))
      arr ~= c.toJson();
    return arr;
  }

  Json getComponent(UUID tenantId, string solutionId, string componentId) {
    _requireSolution(tenantId, solutionId);
    SLMComponent comp;
    if (!_store.tryGetComponent(solutionId, componentId, comp))
      throw new SLMNotFoundException("Component", componentId);
    return comp.toJson();
  }

  // -----------------------------------------------------------------------
  // DEPLOYMENTS – Operation history
  // -----------------------------------------------------------------------

  Json listDeployments(UUID tenantId) {
    return _store.listDeployments(tenantId).map!(d => d.toJson()).array.toJson;
  }

  Json listDeploymentsForSolution(UUID tenantId, string solutionId) {
    _requireSolution(tenantId, solutionId);
    Json arr = Json.emptyArray;
    foreach (d; _store.deploymentsForSolution(tenantId, solutionId))
      arr ~= d.toJson();
    return arr;
  }

  // -----------------------------------------------------------------------
  // SUBSCRIPTIONS – Multitenant solution subscriptions
  // -----------------------------------------------------------------------

  Json listSubscriptions(UUID tenantId) {
    return _store.listSubscriptions(tenantId).map!(s => s.toJson()).array.toJson;
  }

  Json listSubscriptionsForSolution(UUID tenantId, string solutionId) {
    _requireSolution(tenantId, solutionId);
    Json arr = Json.emptyArray;
    foreach (s; _store.subscriptionsForSolution(tenantId, solutionId))
      arr ~= s.toJson();
    return arr;
  }

  /// Subscribe a consumer subaccount to a multitenant solution
  Json subscribe(UUID tenantId, string solutionId, Json payload) {
    SLMSolution sol;
    if (!_store.tryGetSolution(tenantId, solutionId, sol))
      throw new SLMNotFoundException("Solution", solutionId);
    if (!sol.multitenant)
      throw new SLMValidationException("Solution '" ~ sol.name ~ "' is not multitenant");
    if (sol.status != "deployed")
      throw new SLMSolutionStateException("Solution must be deployed to subscribe");

    SLMSubscription sub;
    sub.tenantId = tenantId;
    sub.subscriptionId = jstr(payload, "subscription_id");
    if (sub.subscriptionId.length == 0)
      sub.subscriptionId = _store.nextId("sub");
    sub.solutionId = solutionId;
    sub.consumerSubaccountId = payload["consumer_subaccount_id"].get!string;
    sub.consumerTenantId = jstr(payload, "consumer_tenant_id");
    sub.status = "subscribed";
    sub.entitlementId = jstr(payload, "entitlement_id");
    sub.subscribedBy = jstr(payload, "subscribed_by", "api");
    sub.subscribedAt = Clock.currTime();
    _store.upsertSubscription(sub);

    _appendLog(tenantId, solutionId, "", "subscribed", "info",
      "Consumer " ~ sub.consumerSubaccountId ~ " subscribed to solution");

    return sub.toJson();
  }

  /// Unsubscribe a consumer subaccount
  Json unsubscribe(UUID tenantId, string solutionId, string subscriptionId) {
    _requireSolution(tenantId, solutionId);
    SLMSubscription sub;
    if (!_store.tryGetSubscription(tenantId, subscriptionId, sub))
      throw new SLMNotFoundException("Subscription", subscriptionId);
    if (sub.solutionId != solutionId)
      throw new SLMValidationException("Subscription does not belong to this solution");

    sub.status = "unsubscribed";
    sub.unsubscribedAt = Clock.currTime();
    _store.upsertSubscription(sub);

    _appendLog(tenantId, solutionId, "", "unsubscribed", "info",
      "Consumer " ~ sub.consumerSubaccountId ~ " unsubscribed");

    return sub.toJson();
  }

  // -----------------------------------------------------------------------
  // LICENSES
  // -----------------------------------------------------------------------

  Json listLicensesForSolution(UUID tenantId, string solutionId) {
    _requireSolution(tenantId, solutionId);
    Json arr = Json.emptyArray;
    foreach (l; _store.licensesForSolution(tenantId, solutionId))
      arr ~= l.toJson();
    return arr;
  }

  // -----------------------------------------------------------------------
  // LOGS (monitoring)
  // -----------------------------------------------------------------------

  Json listLogs(UUID tenantId, string solutionId) {
    _requireSolution(tenantId, solutionId);
    Json arr = Json.emptyArray;
    foreach (l; _store.listLogs(tenantId, solutionId))
      arr ~= l.toJson();
    return arr;
  }

  // -----------------------------------------------------------------------
  // Private helpers
  // -----------------------------------------------------------------------

  private SLMSolution _requireSolution(UUID tenantId, string solutionId) {
    SLMSolution sol;
    if (!_store.tryGetSolution(tenantId, solutionId, sol))
      throw new SLMNotFoundException("Solution", solutionId);
    return sol;
  }

  private Json _solutionDetail(UUID tenantId, string solutionId) {
    auto subscriptions = _store.subscriptionsForSolution(tenantId, solutionId)
      .map(sub => sub.toJson()).array;
    auto components = _store.listComponents(solutionId).map(component => component.toJson()).array;
    auto licenses = _store.licensesForSolution(tenantId, solutionId)
      .map(license => license.toJson()).array;

    SLMSolution sol = new SLMSolution();
    if (!_store.tryGetSolution(tenantId, solutionId, sol))
      throw new SLMNotFoundException("Solution", solutionId);

    return sol.toJson()
      .set("components", components)
      .set("subscriptions", subscriptions)
      .set("licenses", licenses);
  }

  /// Create default components from MTA descriptor payload
  private void _createDefaultComponents(string solutionId, Json payload) {
    if ("components" in payload && payload["components"].type == Json.Type.array) {
      foreach (cp; payload["components"].byValue) {
        SLMComponent c;
        c.solutionId = solutionId;
        c.componentId = jstr(cp, "component_id");
        if (c.componentId.length == 0)
          c.componentId = _store.nextId("comp");
        c.name = cp["name"].get!string;
        c.componentType = jstr(cp, "component_type", "module");
        c.status = "started";
        c.url = jstr(cp, "url");
        c.memoryMb = jint(cp, "memory_mb", 256);
        c.instances = jint(cp, "instances", 1);
        c.createdAt = Clock.currTime();
        c.updatedAt = c.createdAt;
        _store.upsertComponent(c);
      }
    } else {
      // Create a single default app component
      SLMComponent c;
      c.solutionId = solutionId;
      c.componentId = _store.nextId("comp");
      c.name = jstr(payload, "name", "app");
      c.componentType = "app";
      c.status = "started";
      c.memoryMb = 256;
      c.instances = 1;
      c.createdAt = Clock.currTime();
      c.updatedAt = c.createdAt;
      _store.upsertComponent(c);
    }
  }

  private void _appendLog(UUID tenantId, string solutionId, string deploymentId,
    string action, string level, string message) {
    SLMOperationLog log;
    log.tenantId = tenantId;
    log.logId = _store.nextId("log");
    log.solutionId = solutionId;
    log.deploymentId = deploymentId;
    log.action = action;
    log.message = message;
    log.level = level;
    log.timestamp = Clock.currTime();
    _store.upsertLog(log);
  }

  // -----------------------------------------------------------------------
  // JSON helpers
  // -----------------------------------------------------------------------
  private static string jstr(Json j, string key, string fallback = "") {
    if (key in j && j[key].type == Json.Type.string)
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

  private static int jint(Json j, string key, int fallback = 0) {
    if (key in j) {
      auto v = j[key];
      if (v.isInteger)
        return v.get!int;
    }
    return fallback;
  }
}
