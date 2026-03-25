module uim.sap.cag.service;

import uim.sap.cag;

mixin(ShowModule!());

@safe:

class CAGService : SAPService {
  mixin(SAPServiceTemplate!CAGService);

  private CAGStore _store;

  this(CAGConfig config) {
    super(config);
    _store = new CAGStore;
  }

  override Json health() {
    CAGConfig cfg = cast(CAGConfig)_config; 

    Json healthInfo = super.health();
    healthInfo["runtime"] = cfg.runtime;
    healthInfo["multitenancy"] = true;
    healthInfo["domain"] = "content-agent";
    return healthInfo;
  }

  string dashboardHtml() const {
    return q"HTML
<!doctype html>
<html>
<head>
  <meta charset=\"utf-8\" />
  <title>UIM Content Agent</title>
  <style>
    body { font-family: Arial, sans-serif; margin: 2rem; max-width: 1200px; }
    h1 { margin-bottom: 0.25rem; }
    .row { display: flex; gap: 0.75rem; margin: 0.5rem 0; flex-wrap: wrap; }
    input, select, button { padding: 0.5rem; }
    pre { background: #f6f8fa; padding: 1rem; overflow: auto; border-radius: 8px; }
  </style>
</head>
<body>
  <h1>Content Agent Service</h1>
    <p>
      Assemble tenant content into MTAR metadata and export to transport queues
      (CTS+/Cloud Transport Management).
    </p>

  <div class=\"row\">
    <input id=\"tenant\" value=\"acme\" placeholder=\"tenant\" />
    <button onclick=\"refreshAll()\">Refresh</button>
  </div>

  <h3>Provider</h3>
  <div class=\"row\">
    <input id=\"providerId\" placeholder=\"provider id\" />
    <input id=\"providerName\" placeholder=\"provider name\" />
    <input id=\"providerEndpoint\" placeholder=\"provider endpoint\" style=\"width:300px\" />
    <button onclick=\"createProvider()\">Save Provider</button>
  </div>

  <h3>Content</h3>
  <div class=\"row\">
    <input id=\"contentId\" placeholder=\"content id\" />
    <input id=\"contentTitle\" placeholder=\"title\" />
    <select id="contentType">
      <option>application</option><option>integration</option>
      <option>workflow</option><option>destination</option><option>role</option>
    </select>
    <input id=\"contentDeps\" placeholder=\"dependencies (comma separated ids)\" style=\"width:300px\" />
    <button onclick=\"createContent()\">Save Content</button>
  </div>

  <h3>Transport Queue</h3>
  <div class=\"row\">
    <input id=\"queueId\" placeholder=\"queue id\" />
    <input id=\"queueName\" placeholder=\"queue name\" />
    <select id="queueType">
      <option>cloud-transport-management</option><option>ctsplus</option>
    </select>
    <input id=\"queueEndpoint\" placeholder=\"queue endpoint\" style=\"width:300px\" />
    <button onclick=\"createQueue()\">Save Queue</button>
  </div>

  <h3>Assembly and Export</h3>
  <div class=\"row\">
    <input id=\"assemblyName\" placeholder=\"assembly name\" />
    <input id=\"sourceSubaccount\" placeholder=\"source subaccount\" value=\"dev-subaccount\" />
    <input id=\"targetSubaccount\" placeholder=\"target subaccount\" value=\"prod-subaccount\" />
    <input id=\"assemblyContentIds\" placeholder=\"content ids (comma separated)\" style=\"width:320px\" />
    <button onclick=\"createAssembly()\">Create MTAR Assembly</button>
  </div>
  <div class=\"row\">
    <input id=\"exportAssemblyId\" placeholder=\"assembly id\" />
    <input id=\"exportQueueId\" placeholder=\"queue id\" />
    <button onclick=\"exportAssembly()\">Export Assembly</button>
  </div>

  <h3>Data</h3>
  <pre id=\"out\">Loading...</pre>

  <script>
    function tenant() { return document.getElementById('tenant').value || 'acme'; }
    function base() { return '/api/content-agent/v1/tenants/' + tenant(); }
    function splitCsv(id) {
      const raw = document.getElementById(id).value || '';
      return raw.split(',').map(x => x.trim()).filter(Boolean);
    }

    async function refreshAll() {
      const [providers, content, queues, assemblies, activities] = await Promise.all([
        fetch(base() + '/providers').then(r => r.json()),
        fetch(base() + '/content').then(r => r.json()),
        fetch(base() + '/queues').then(r => r.json()),
        fetch(base() + '/assemblies').then(r => r.json()),
        fetch(base() + '/activities').then(r => r.json())
      ]);
      document.getElementById('out').textContent = JSON.stringify(
        {providers, content, queues, assemblies, activities},
        null,
        2
      );
    }

    async function createProvider() {
      await fetch(base() + '/providers', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          provider_id: document.getElementById('providerId').value,
          name: document.getElementById('providerName').value,
          endpoint: document.getElementById('providerEndpoint').value,
          provider_type: 'sap-content-provider',
          supported_types: ['application', 'integration', 'workflow', 'destination', 'role']
        })
      });
      refreshAll();
    }

    async function createContent() {
      await fetch(base() + '/content', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          content_id: document.getElementById('contentId').value,
          title: document.getElementById('contentTitle').value,
          content_type: document.getElementById('contentType').value,
          dependencies: splitCsv('contentDeps'),
          provider_id: document.getElementById('providerId').value || 'manual',
          version: '1.0.0'
        })
      });
      refreshAll();
    }

    async function createQueue() {
      await fetch(base() + '/queues', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          queue_id: document.getElementById('queueId').value,
          name: document.getElementById('queueName').value,
          queue_type: document.getElementById('queueType').value,
          endpoint: document.getElementById('queueEndpoint').value
        })
      });
      refreshAll();
    }

    async function createAssembly() {
      const response = await fetch(base() + '/assemblies', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          name: document.getElementById('assemblyName').value,
          source_subaccount: document.getElementById('sourceSubaccount').value,
          target_subaccount: document.getElementById('targetSubaccount').value,
          content_ids: splitCsv('assemblyContentIds'),
          include_dependencies: true,
          created_by: 'ui-user'
        })
      });
      const data = await response.json();
      if (data.assembly && data.assembly.assembly_id) {
        document.getElementById('exportAssemblyId').value = data.assembly.assembly_id;
      }
      refreshAll();
    }

    async function exportAssembly() {
      await fetch(base() + '/assemblies/' + document.getElementById('exportAssemblyId').value + '/export', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({
          queue_id: document.getElementById('exportQueueId').value,
          initiated_by: 'ui-user'
        })
      });
      refreshAll();
    }

    refreshAll();
  </script>
</body>
</html>
HTML";
  }

  Json listProviders(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (provider; _store.listProviders(tenantId))
      resources ~= provider.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertProvider(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto providerid = requiredUUID(body, "provider_id");
    auto now = Clock.currTime();

    CAGContentProvider existing;
    bool hasExisting = _store.tryGetProvider(tenantId, providerId, existing);

    CAGContentProvider provider;
    provider.tenantId = tenantId;
    provider.providerId = providerId;
    provider.name = requiredString(body, "name");
    provider.providerType = optionalString(body, "provider_type", "sap-content-provider");
    provider.endpoint = optionalString(body, "endpoint", "");
    provider.supportedTypes = normalizeContentTypes(readStringArray(body, "supported_types"));
    if (provider.supportedTypes.length == 0) {
      provider.supportedTypes = [
        "application", "integration", "workflow", "destination", "role"
      ];
    }
    provider.active = optionalBoolean(data, "active", true);
    provider.createdAt = hasExisting ? existing.createdAt : now;
    provider.updatedAt = now;

    auto saved = _store.upsertProvider(provider);

    return Json.emptyObject
      .set("message", "Content provider saved")
      .set("provider", saved.toJson());
  }

  Json listContent(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listContent(tenantId))
      resources ~= item.toJson();

    Json payload = Json.emptyObject;
    payload["tenant_id"] = tenantId;
    payload["resources"] = resources;
    payload["total_results"] = cast(long)resources.length;
    return payload;
  }

  Json upsertContent(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto contentid = requiredUUID(data, "content_id");
    auto now = Clock.currTime();

    CAGContentItem existing;
    bool hasExisting = _store.tryGetContent(tenantId, contentId, existing);

    CAGContentItem item;
    item.tenantId = tenantId;
    item.contentId = contentId;
    item.title = requiredString(data, "title");
    item.contentType = normalizeContentType(optionalString(data, "content_type", "application"));
    item.contentVersion = optionalString(data, "version", "1.0.0");
    item.providerId = optionalString(data, "provider_id", "manual");
    item.dependencies = readStringArray(data, "dependencies");
    item.relatedContent = readStringArray(data, "related_content");
    item.metadata = readObject(data, "metadata");
    item.createdAt = hasExisting ? existing.createdAt : now;
    item.updatedAt = now;

    auto saved = _store.upsertContent(item);

    return Json.emptyObject
      .set("message", "Content item saved")
      .set("item", saved.toJson());
  }

  Json getContent(UUID tenantId, string contentId) {
    validateTenant(tenantId);
    validateId(contentId, "content_id");

    CAGContentItem item;
    if (!_store.tryGetContent(tenantId, contentId, item)) {
      throw new CAGNotFoundException("content item not found");
    }

    auto dependencyIds = resolveDependencies(tenantId, item.dependencies);
    Json dependencyDetails = Json.emptyArray;
    foreach (id; dependencyIds) {
      CAGContentItem dep;
      if (_store.tryGetContent(tenantId, id, dep))
        dependencyDetails ~= dep.toJson();
    }

    return Json.emptyObject
      .set("item", item.toJson())
      .set("dependency_details", dependencyDetails);
  }

  Json listQueues(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = _store.listQueues(tenantId).map!(queue => queue.toJson()).array;  

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json upsertQueue(UUID tenantId, Json data) {
    validateTenant(tenantId);
    auto queueid = requiredUUID(body, "queue_id");
    auto now = Clock.currTime();

    CAGTransportQueue existing;
    bool hasExisting = _store.tryGetQueue(tenantId, queueId, existing);

    CAGTransportQueue queue;
    queue.tenantId = tenantId;
    queue.queueId = queueId;
    queue.name = requiredString(data, "name");
    queue.queueType = normalizeQueueType(requiredString(data, "queue_type"));
    queue.endpoint = optionalString(data, "endpoint", "");
    queue.active = optionalBoolean(data, "active", true);
    queue.createdAt = hasExisting ? existing.createdAt : now;
    queue.updatedAt = now;

    auto saved = _store.upsertQueue(queue);

    return Json.emptyObject
      .set("message", "Transport queue saved")
      .set("queue", saved.toJson());
  }

  Json listAssemblies(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listAssemblies(tenantId))
      resources ~= item.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  Json createAssembly(UUID tenantId, Json data) {
    validateTenant(tenantId);

    auto sourceSubaccount = requiredString(body, "source_subaccount");
    auto targetSubaccount = requiredString(body, "target_subaccount");
    auto name = requiredString(body, "name");
    auto requestedIds = readStringArray(body, "content_ids");
    if (requestedIds.length == 0)
      throw new CAGValidationException("content_ids must contain at least one entry");

    foreach (id; requestedIds) {
      CAGContentItem item;
      if (!_store.tryGetContent(tenantId, id, item)) {
        throw new CAGValidationException("content id not found: " ~ id);
      }
    }

    auto includeDependencies = optionalBoolean(data, "include_dependencies", true);
    auto resolvedIds = requestedIds.dup;
    if (includeDependencies) {
      auto additional = resolveDependencies(tenantId, requestedIds);
      foreach (id; additional)
        if (!contains(resolvedIds, id))
          resolvedIds ~= id;
    }

    auto now = Clock.currTime();
    auto assemblyId = _store.nextId("assembly");

    CAGAssembly assembly;
    assembly.tenantId = tenantId;
    assembly.assemblyId = assemblyId;
    assembly.name = name;
    assembly.sourceSubaccount = sourceSubaccount;
    assembly.targetSubaccount = targetSubaccount;
    assembly.requestedContentIds = requestedIds;
    assembly.resolvedContentIds = resolvedIds;
    assembly.includeDependencies = includeDependencies;
    assembly.mtarName = tenantId ~ "-" ~ assemblyId ~ ".mtar";
    assembly.mtarDownloadUrl = _config.basePath ~ "/v1/tenants/" ~ tenantId ~ "/assemblies/" ~ assemblyId ~ "/mtar";
    assembly.status = "ASSEMBLED";
    assembly.createdAt = now;
    assembly.updatedAt = now;

    auto saved = _store.upsertAssembly(assembly);

    Json manifestItems = Json.emptyArray;
    foreach (contentId; saved.resolvedContentIds) {
      CAGContentItem item;
      if (_store.tryGetContent(tenantId, contentId, item))
        manifestItems ~= item.toJson();
    }

    return Json.emptyObject
      .set("message", "Content assembled into MTAR metadata")
      .set("assembly", saved.toJson())
      .set("manifest_items", manifestItems)
      .set("created_by", optionalString(body, "created_by", "system"));
  }

  Json getAssembly(UUID tenantId, string assemblyId) {
    validateTenant(tenantId);
    validateId(assemblyId, "assembly_id");

    CAGAssembly assembly;
    if (!_store.tryGetAssembly(tenantId, assemblyId, assembly)) {
      throw new CAGNotFoundException("assembly not found");
    }

    return Json.emptyObject
      .set("assembly", assembly.toJson());
  }

  Json getMtarMetadata(UUID tenantId, string assemblyId) {
    validateTenant(tenantId);
    validateId(assemblyId, "assembly_id");

    CAGAssembly assembly;
    if (!_store.tryGetAssembly(tenantId, assemblyId, assembly)) {
      throw new CAGNotFoundException("assembly not found");
    }

    Json modules = Json.emptyArray;
    foreach (contentId; assembly.resolvedContentIds) {
      CAGContentItem item;
      if (_store.tryGetContent(tenantId, contentId, item)) {
        Json moduleData = Json.emptyObject
          .set("name", item.contentId)
          .set("type", item.contentType)
          .set("version", item.contentVersion);
        modules ~= moduleData;
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("assembly_id", assemblyId)
      .set("mtar_name", assembly.mtarName)
      .set("download_url", assembly.mtarDownloadUrl)
      .set("modules", modules);

  }

  Json exportAssembly(UUID tenantId, string assemblyId, Json data) {
    validateTenant(tenantId);
    validateId(assemblyId, "assembly_id");

    CAGAssembly assembly;
    if (!_store.tryGetAssembly(tenantId, assemblyId, assembly)) {
      throw new CAGNotFoundException("assembly not found");
    }

    auto queueid = requiredUUID(body, "queue_id");
    CAGTransportQueue queue;
    if (!_store.tryGetQueue(tenantId, queueId, queue)) {
      throw new CAGValidationException("queue_id not found");
    }
    if (!queue.active)
      throw new CAGValidationException("queue is inactive");

    Json contentIds = Json.emptyArray;
    foreach (id; assembly.resolvedContentIds)
      contentIds ~= id;

    Json exportPayload = Json.emptyObject
      .set("assembly_id", assembly.assemblyId)
      .set("mtar_name", assembly.mtarName)
      .set("source_subaccount", assembly.sourceSubaccount)
      .set("target_subaccount", assembly.targetSubaccount)
      .set("queue_id", queue.queueId)
      .set("queue_type", queue.queueType)
      .set("queue_endpoint", queue.endpoint)
      .set("runtime", _config.runtime)
      .set("content_ids", contentIds);

    auto now = Clock.currTime();
    CAGTransportActivity activity;
    activity.tenantId = tenantId;
    activity.activityId = _store.nextId("activity");
    activity.assemblyId = assemblyId;
    activity.queueId = queue.queueId;
    activity.status = "EXPORTED";
    activity.message = "Assembly exported to transport queue";
    activity.initiatedBy = optionalString(body, "initiated_by", "system");
    activity.exportPayload = exportPayload;
    activity.createdAt = now;

    auto saved = _store.upsertActivity(activity);

    return Json.emptyObject
      .set("message", "Assembly exported successfully")
      .set("activity", saved.toJson());
  }

  Json listActivities(UUID tenantId) {
    validateTenant(tenantId);
    Json resources = Json.emptyArray;
    foreach (item; _store.listActivities(tenantId))
      resources ~= item.toJson();

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long)resources.length);
  }

  private string[] resolveDependencies(UUID tenantId, string[] seedIds) {
    bool[string] visited;
    string[] ordered;
    string[] queue = seedIds.dup;

    while (queue.length > 0) {
      auto id = queue[0];
      queue = queue[1 .. $];
      if ((id in visited) !is null)
        continue;
      visited[id] = true;

      CAGContentItem item;
      if (!_store.tryGetContent(tenantId, id, item))
        continue;
      foreach (dep; item.dependencies) {
        if (!contains(ordered, dep))
          ordered ~= dep;
        if ((dep in visited) is null)
          queue ~= dep;
      }
    }

    return ordered.array;
  }



  private void validateTenant(UUID tenantId) const {
    if (tenantId.length == 0)
      throw new CAGValidationException("tenant_id is required");
  }

  private string normalizeContentType(string value) const {
    auto normalized = toLower(value);
    if (normalized != "application"
      && normalized != "integration"
      && normalized != "workflow"
      && normalized != "destination"
      && normalized != "role") {
      throw new CAGValidationException(
        "content_type must be one of application|integration|workflow|destination|role"
      );
    }
    return normalized;
  }

  private string[] normalizeContentTypes(string[] values) const {
    return values.map!(value => normalizeContentType(value)).array;
  }

  private string normalizeQueueType(string value) const {
    auto normalized = toLower(value);
    if (normalized == "ctm")
      normalized = "cloud-transport-management";
    if (normalized != "ctsplus" && normalized != "cloud-transport-management") {
      throw new CAGValidationException("queue_type must be ctsplus or cloud-transport-management");
    }
    return normalized;
  }
}
