module uim.sap.slm.store;

import std.algorithm : sort;
import std.array     : array;
import std.conv      : to;
import std.string    : startsWith;

import uim.sap.slm.models;

// ---------------------------------------------------------------------------
// SLMStore – thread-safe in-memory store for all solution lifecycle entities
// ---------------------------------------------------------------------------
class SLMStore : SAPStore {
    private SLMSolution[string]      _solutions;
    private SLMComponent[string]     _components;    // key: solutionId::componentId
    private SLMDeployment[string]    _deployments;
    private SLMSubscription[string]  _subscriptions;
    private SLMLicense[string]       _licenses;
    private SLMOperationLog[string]  _logs;
    private long _counter = 0;

    // -----------------------------------------------------------------------
    // ID generation
    // -----------------------------------------------------------------------
    string nextId(string prefix) {
        _counter += 1;
        return prefix ~ "-" ~ to!string(_counter);
    }

    // -----------------------------------------------------------------------
    // Key helpers
    // -----------------------------------------------------------------------
    private static string tp(UUID tenantId) {
        return tenantId ~ "::";
    }

    private static string key(UUID tenantId, string id) {
        return tenantId ~ "::" ~ id;
    }

    private static string key3(string a, string b, string c) {
        return a ~ "::" ~ b ~ "::" ~ c;
    }

    // -----------------------------------------------------------------------
    // Solutions
    // -----------------------------------------------------------------------
    SLMSolution upsertSolution(SLMSolution item) {
        _solutions[key(item.tenantId, item.solutionId)] = item;
        return item;
    }

    SLMSolution[] listSolutions(UUID tenantId) {
        SLMSolution[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _solutions) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetSolution(UUID tenantId, string solutionId, out SLMSolution sol) {
        auto k = key(tenantId, solutionId);
        if (k in _solutions) { sol = _solutions[k]; return true; }
        return false;
    }

    bool removeSolution(UUID tenantId, string solutionId) {
        auto k = key(tenantId, solutionId);
        if (k in _solutions) { _solutions.remove(k); return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Components
    // -----------------------------------------------------------------------
    SLMComponent upsertComponent(SLMComponent item) {
        _components[item.solutionId ~ "::" ~ item.componentId] = item;
        return item;
    }

    SLMComponent[] listComponents(string solutionId) {
        SLMComponent[] items;
        auto prefix = solutionId ~ "::";
        foreach (k, v; _components) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetComponent(string solutionId, string componentId, out SLMComponent comp) {
        auto k = solutionId ~ "::" ~ componentId;
        if (k in _components) { comp = _components[k]; return true; }
        return false;
    }

    void removeComponentsForSolution(string solutionId) {
        string[] toRemove;
        auto prefix = solutionId ~ "::";
        foreach (k, v; _components)
            if (k.startsWith(prefix)) toRemove ~= k;
        foreach (k; toRemove) _components.remove(k);
    }

    // -----------------------------------------------------------------------
    // Deployments
    // -----------------------------------------------------------------------
    SLMDeployment upsertDeployment(SLMDeployment item) {
        _deployments[key(item.tenantId, item.deploymentId)] = item;
        return item;
    }

    SLMDeployment[] listDeployments(UUID tenantId) {
        SLMDeployment[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _deployments) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    SLMDeployment[] deploymentsForSolution(UUID tenantId, string solutionId) {
        SLMDeployment[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _deployments)
            if (k.startsWith(prefix) && v.solutionId == solutionId)
                items ~= v;
        items.sort!((a, b) => a.startedAt < b.startedAt);
        return items.array;
    }

    bool tryGetDeployment(UUID tenantId, string deploymentId, out SLMDeployment dep) {
        auto k = key(tenantId, deploymentId);
        if (k in _deployments) { dep = _deployments[k]; return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Subscriptions
    // -----------------------------------------------------------------------
    SLMSubscription upsertSubscription(SLMSubscription item) {
        _subscriptions[key(item.tenantId, item.subscriptionId)] = item;
        return item;
    }

    SLMSubscription[] listSubscriptions(UUID tenantId) {
        SLMSubscription[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _subscriptions) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    SLMSubscription[] subscriptionsForSolution(UUID tenantId, string solutionId) {
        SLMSubscription[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _subscriptions)
            if (k.startsWith(prefix) && v.solutionId == solutionId)
                items ~= v;
        return items;
    }

    bool tryGetSubscription(UUID tenantId, string subscriptionId, out SLMSubscription sub) {
        auto k = key(tenantId, subscriptionId);
        if (k in _subscriptions) { sub = _subscriptions[k]; return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Licenses
    // -----------------------------------------------------------------------
    SLMLicense upsertLicense(SLMLicense item) {
        _licenses[key(item.tenantId, item.licenseId)] = item;
        return item;
    }

    SLMLicense[] listLicenses(UUID tenantId) {
        SLMLicense[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _licenses) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    SLMLicense[] licensesForSolution(UUID tenantId, string solutionId) {
        SLMLicense[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _licenses)
            if (k.startsWith(prefix) && v.solutionId == solutionId)
                items ~= v;
        return items;
    }

    // -----------------------------------------------------------------------
    // Logs
    // -----------------------------------------------------------------------
    SLMOperationLog upsertLog(SLMOperationLog item) {
        _logs[key(item.tenantId, item.logId)] = item;
        return item;
    }

    SLMOperationLog[] listLogs(UUID tenantId, string solutionId) {
        SLMOperationLog[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _logs)
            if (k.startsWith(prefix) && v.solutionId == solutionId)
                items ~= v;
        items.sort!((a, b) => a.timestamp < b.timestamp);
        return items.array;
    }

    SLMOperationLog[] listAllLogs(UUID tenantId) {
        SLMOperationLog[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _logs) if (k.startsWith(prefix)) items ~= v;
        items.sort!((a, b) => a.timestamp < b.timestamp);
        return items.array;
    }
}
