module uim.sap.cid.store;

import uim.sap.cid;

mixin(ShowModule!());

@safe:

// ---------------------------------------------------------------------------
// CIDStore – in-memory multi-tenant store for CI/CD entities
// ---------------------------------------------------------------------------
class CIDStore : SAPStore {
  mixin(SAPStoreTemplate!CIDStore);
  
    private CIDRepository[string]  _repos;
    private CIDCredential[string]  _creds;
    private CIDPipeline[string]    _pipelines;
    private CIDBuild[string]       _builds;
    private CIDBuildStage[string]  _stages;      // key: buildId::stageId
    private CIDBuildLog[string]    _logs;
    private long _counter = 0;

    // -----------------------------------------------------------------------
    // ID / key helpers
    // -----------------------------------------------------------------------
    string nextId(string prefix) {
        _counter += 1;
        return prefix ~ "-" ~ to!string(_counter);
    }

    private static string tp(UUID tenantId) {
        return tenantId ~ "::";
    }

    private static string key(UUID tenantId, string id) {
        return tenantId ~ "::" ~ id;
    }

    private static string key3(string a, string b) {
        return a ~ "::" ~ b;
    }

    // -----------------------------------------------------------------------
    // Repositories
    // -----------------------------------------------------------------------
    CIDRepository upsertRepo(CIDRepository item) {
        _repos[key(item.tenantId, item.repoId)] = item;
        return item;
    }

    CIDRepository[] listRepos(UUID tenantId) {
        CIDRepository[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _repos) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetRepo(UUID tenantId, string repoId, out CIDRepository repo) {
        auto k = key(tenantId, repoId);
        if (k in _repos) { repo = _repos[k]; return true; }
        return false;
    }

    bool removeRepo(UUID tenantId, string repoId) {
        auto k = key(tenantId, repoId);
        if (k in _repos) { _repos.remove(k); return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Credentials
    // -----------------------------------------------------------------------
    CIDCredential upsertCredential(CIDCredential item) {
        _creds[key(item.tenantId, item.credentialId)] = item;
        return item;
    }

    CIDCredential[] listCredentials(UUID tenantId) {
        CIDCredential[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _creds) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetCredential(UUID tenantId, string credId, out CIDCredential cred) {
        auto k = key(tenantId, credId);
        if (k in _creds) { cred = _creds[k]; return true; }
        return false;
    }

    bool removeCredential(UUID tenantId, string credId) {
        auto k = key(tenantId, credId);
        if (k in _creds) { _creds.remove(k); return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Pipelines
    // -----------------------------------------------------------------------
    CIDPipeline upsertPipeline(CIDPipeline item) {
        _pipelines[key(item.tenantId, item.pipelineId)] = item;
        return item;
    }

    CIDPipeline[] listPipelines(UUID tenantId) {
        CIDPipeline[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _pipelines) if (k.startsWith(prefix)) items ~= v;
        return items;
    }

    bool tryGetPipeline(UUID tenantId, string pipelineId, out CIDPipeline pipeline) {
        auto k = key(tenantId, pipelineId);
        if (k in _pipelines) { pipeline = _pipelines[k]; return true; }
        return false;
    }

    bool removePipeline(UUID tenantId, string pipelineId) {
        auto k = key(tenantId, pipelineId);
        if (k in _pipelines) { _pipelines.remove(k); return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Builds
    // -----------------------------------------------------------------------
    CIDBuild upsertBuild(CIDBuild item) {
        _builds[key(item.tenantId, item.buildId)] = item;
        return item;
    }

    CIDBuild[] listBuilds(UUID tenantId) {
        CIDBuild[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _builds) if (k.startsWith(prefix)) items ~= v;
        items.sort!((a, b) => a.createdAt > b.createdAt);
        return items.array;
    }

    CIDBuild[] listBuildsByPipeline(UUID tenantId, string pipelineId) {
        CIDBuild[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _builds)
            if (k.startsWith(prefix) && v.pipelineId == pipelineId)
                items ~= v;
        items.sort!((a, b) => a.buildNumber > b.buildNumber);
        return items.array;
    }

    bool tryGetBuild(UUID tenantId, string buildId, out CIDBuild build) {
        auto k = key(tenantId, buildId);
        if (k in _builds) { build = _builds[k]; return true; }
        return false;
    }

    /// Return the highest build number for a pipeline (0 if none)
    int maxBuildNumber(UUID tenantId, string pipelineId) {
        int maxN = 0;
        auto prefix = tp(tenantId);
        foreach (k, v; _builds)
            if (k.startsWith(prefix) && v.pipelineId == pipelineId && v.buildNumber > maxN)
                maxN = v.buildNumber;
        return maxN;
    }

    // -----------------------------------------------------------------------
    // Build Stages
    // -----------------------------------------------------------------------
    CIDBuildStage upsertStage(CIDBuildStage item) {
        _stages[key3(item.buildId, item.stageId)] = item;
        return item;
    }

    CIDBuildStage[] listStages(string buildId) {
        CIDBuildStage[] items;
        auto prefix = buildId ~ "::";
        foreach (k, v; _stages) if (k.startsWith(prefix)) items ~= v;
        items.sort!((a, b) => a.ordinal < b.ordinal);
        return items.array;
    }

    bool tryGetStage(string buildId, string stageId, out CIDBuildStage stage) {
        auto k = key3(buildId, stageId);
        if (k in _stages) { stage = _stages[k]; return true; }
        return false;
    }

    // -----------------------------------------------------------------------
    // Build Logs
    // -----------------------------------------------------------------------
    CIDBuildLog upsertLog(CIDBuildLog item) {
        _logs[key(item.tenantId, item.logId)] = item;
        return item;
    }

    CIDBuildLog[] listLogs(UUID tenantId, string buildId) {
        CIDBuildLog[] items;
        auto prefix = tp(tenantId);
        foreach (k, v; _logs)
            if (k.startsWith(prefix) && v.buildId == buildId)
                items ~= v;
        items.sort!((a, b) => a.timestamp < b.timestamp);
        return items.array;
    }
}
