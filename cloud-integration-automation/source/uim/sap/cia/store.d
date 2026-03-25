module uim.sap.cia.store;

import uim.sap.cia;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIAStore – thread-safe in-memory store for all CIA entities
// ---------------------------------------------------------------------------
class CIAStore : SAPStore {
  mixin(SAPStoreTemplate!CIAStore);

  protected CIARole[string] _roles;
  protected CIAUser[string] _users;
  protected CIASystem[string] _systems;
  protected CIAScenario[string] _scenarios;
  protected CIAWorkflow[string] _workflows;
  protected CIATask[string] _tasks;
  protected CIAParameter[string] _parameters;
  protected CIATaskLog[string] _logs;
  protected CIAAutomationResult[string] _automationResults;
  protected long _counter = 0;

  // -----------------------------------------------------------------------
  // ID generation
  // -----------------------------------------------------------------------
  string nextId(string prefix) {
    _counter += 1;
    return prefix ~ "-" ~ to!string(_counter);
  }

  // -----------------------------------------------------------------------
  // Keys
  // -----------------------------------------------------------------------
  private static string tenantPrefix(UUID tenantId) {
    return tenantId ~ "::";
  }

  private static string key(UUID tenantId, string id) {
    return tenantId ~ "::" ~ id;
  }

  // -----------------------------------------------------------------------
  // Roles  (global, not tenant-scoped for simplicity)
  // -----------------------------------------------------------------------
  CIARole upsertRole(CIARole item) {
    _roles[item.id] = item;
    return item;
  }

  CIARole[] listRoles() {
    CIARole[] items;
    foreach (v; _roles)
      items ~= v;
    return items;
  }

  bool tryGetRole(string id, out CIARole role) {
    if (id in _roles) {
      role = _roles[id];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Users
  // -----------------------------------------------------------------------
  CIAUser upsertUser(CIAUser item) {
    _users[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIAUser[] listUsers(UUID tenantId) {
    CIAUser[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _users)
      if (k.startsWith(prefix))
        items ~= v;
    return items.array;
  }

  bool tryGetUser(UUID tenantId, string id, out CIAUser user) {
    auto k = key(tenantId, id);
    if (k in _users) {
      user = _users[k];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Systems (landscape)
  // -----------------------------------------------------------------------
  CIASystem upsertSystem(CIASystem item) {
    _systems[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIASystem[] listSystems(UUID tenantId) {
    CIASystem[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _systems)
      if (k.startsWith(prefix))
        items ~= v;
    return items.array;
  }

  bool tryGetSystem(UUID tenantId, string id, out CIASystem system) {
    auto k = key(tenantId, id);
    if (k in _systems) {
      system = _systems[k];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Scenarios
  // -----------------------------------------------------------------------
  CIAScenario upsertScenario(CIAScenario item) {
    _scenarios[item.id] = item;
    return item;
  }

  CIAScenario[] listScenarios() {
    CIAScenario[] items;
    foreach (v; _scenarios)
      items ~= v;
    return items;
  }

  bool tryGetScenario(string id, out CIAScenario scenario) {
    if (id in _scenarios) {
      scenario = _scenarios[id];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Workflows
  // -----------------------------------------------------------------------
  CIAWorkflow upsertWorkflow(CIAWorkflow item) {
    _workflows[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIAWorkflow[] listWorkflows(UUID tenantId) {
    CIAWorkflow[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _workflows)
      if (k.startsWith(prefix))
        items ~= v;
    return items.array;
  }

  bool tryGetWorkflow(UUID tenantId, string id, out CIAWorkflow workflow) {
    auto k = key(tenantId, id);
    if (k in _workflows) {
      workflow = _workflows[k];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Tasks
  // -----------------------------------------------------------------------
  CIATask upsertTask(CIATask item) {
    _tasks[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIATask[] listTasks(UUID tenantId, UUID workflowId) {
    import std.algorithm : sort;

    CIATask[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _tasks)
      if (k.startsWith(prefix) && v.workflowId == workflowId)
        items ~= v;
    items.sort!((a, b) => a.order < b.order);
    return items.array;
  }

  bool tryGetTask(UUID tenantId, string id, out CIATask task) {
    auto k = key(tenantId, id);
    if (k in _tasks) {
      task = _tasks[k];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Parameters (keyed by workflowId + paramKey)
  // -----------------------------------------------------------------------
  CIAParameter upsertParameter(CIAParameter item) {
    _parameters[item.workflowId ~ "::" ~ item.key] = item;
    return item;
  }

  CIAParameter[] listParameters(UUID workflowId) {
    CIAParameter[] items;
    auto prefix = workflowId ~ "::";
    foreach (k, v; _parameters)
      if (k.startsWith(prefix))
        items ~= v;
    return items.array;
  }

  bool tryGetParameter(UUID workflowId, string paramKey, out CIAParameter param) {
    auto k = workflowId ~ "::" ~ paramKey;
    if (k in _parameters) {
      param = _parameters[k];
      return true;
    }
    return false;
  }

  // -----------------------------------------------------------------------
  // Logs
  // -----------------------------------------------------------------------
  CIATaskLog upsertLog(CIATaskLog item) {
    _logs[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIATaskLog[] listLogs(UUID tenantId, UUID workflowId) {
    import std.algorithm : sort;

    CIATaskLog[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _logs)
      if (k.startsWith(prefix) && v.workflowId == workflowId)
        items ~= v;
    items.sort!((a, b) => a.timestamp < b.timestamp);
    return items.array;
  }

  // -----------------------------------------------------------------------
  // Automation Results
  // -----------------------------------------------------------------------
  CIAAutomationResult upsertAutomationResult(CIAAutomationResult item) {
    _automationResults[key(item.tenantId, item.id)] = item;
    return item;
  }

  CIAAutomationResult[] listAutomationResults(UUID tenantId, string taskId) {
    CIAAutomationResult[] items;
    auto prefix = tenantPrefix(tenantId);
    foreach (k, v; _automationResults)
      if (k.startsWith(prefix) && v.taskId == taskId)
        items ~= v;
    return items.array;
  }
}
