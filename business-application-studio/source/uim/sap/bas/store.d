module uim.sap.bas.store;

import core.sync.mutex : Mutex;

import uim.sap.bas;

mixin(ShowModule!());

@safe:

class BASStore : SAPStore {
  private BASWorkspace[string] _workspaces;
  private BASWizardRun[string] _wizardRuns;
  private BASTerminalSession[string] _terminalSessions;
  private BASDeployment[string] _deployments;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  BASWorkspace upsertWorkspace(BASWorkspace workspace) {
    synchronized (_lock) {
      auto key = scoped("workspace", workspace.tenantId, workspace.workspaceId);
      if (auto existing = key in _workspaces)
        workspace.createdAt = existing.createdAt;
      _workspaces[key] = workspace;
      return workspace;
    }
  }

  BASWorkspace[] listWorkspaces(UUID tenantId) {
    BASWorkspace[] values;
    synchronized (_lock) {
      foreach (key, value; _workspaces) {
        if (belongs(key, tenantId, "workspace"))
          values ~= value;
      }
    }
    return values;
  }

  Nullable!BASWorkspace getWorkspace(UUID tenantId, string workspaceId) {
    synchronized (_lock) {
      auto key = scoped("workspace", tenantId, workspaceId);
      if (auto value = key in _workspaces)
        return Nullable!BASWorkspace(*value);
      return Nullable!BASWorkspace.init;
    }
  }

  BASWizardRun upsertWizardRun(BASWizardRun run) {
    synchronized (_lock) {
      _wizardRuns[scoped("wizard", run.tenantId, run.runId)] = run;
      return run;
    }
  }

  BASWizardRun[] listWizardRuns(UUID tenantId, string workspaceId) {
    BASWizardRun[] values;
    synchronized (_lock) {
      foreach (key, value; _wizardRuns) {
        if (!belongs(key, tenantId, "wizard"))
          continue;
        if (value.workspaceId != workspaceId)
          continue;
        values ~= value;
      }
    }
    return values;
  }

  BASTerminalSession upsertTerminalSession(BASTerminalSession session) {
    synchronized (_lock) {
      _terminalSessions[scoped("terminal", session.tenantId, session.sessionId)] = session;
      return session;
    }
  }

  BASTerminalSession[] listTerminalSessions(UUID tenantId, string workspaceId) {
    BASTerminalSession[] values;
    synchronized (_lock) {
      foreach (key, value; _terminalSessions) {
        if (!belongs(key, tenantId, "terminal"))
          continue;
        if (value.workspaceId != workspaceId)
          continue;
        values ~= value;
      }
    }
    return values;
  }

  BASDeployment upsertDeployment(BASDeployment deployment) {
    synchronized (_lock) {
      _deployments[scoped("deployment", deployment.tenantId, deployment.deploymentId)] = deployment;
      return deployment;
    }
  }

  BASDeployment[] listDeployments(UUID tenantId, string workspaceId) {
    BASDeployment[] values;
    synchronized (_lock) {
      foreach (key, value; _deployments) {
        if (!belongs(key, tenantId, "deployment"))
          continue;
        if (value.workspaceId != workspaceId)
          continue;
        values ~= value;
      }
    }
    return values;
  }

  private string scoped(string kind, UUID tenantId, string id) {
    return tenantId ~ ":" ~ kind ~ ":" ~ id;
  }

  private bool belongs(string key, UUID tenantId, string kind) {
    auto prefix = tenantId ~ ":" ~ kind ~ ":";
    return key.length >= prefix.length && key[0 .. prefix.length] == prefix;
  }
}
