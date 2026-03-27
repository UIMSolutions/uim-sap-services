module app;

import std.algorithm : map;
import std.array : array;
import std.datetime : SysTime;
import std.json;
import std.string : toLower;

import vibe.vibe;

import config;
import models;
import providers;
import services;

private string ts(SysTime t) {
  return t.toString();
}

private void writeJson(HTTPServerResponse res, Json payload, int code = 200) {
  res.statusCode = code;
  res.contentType = "application/json; charset=utf-8";
  res.writeBody(payload.toString());
}

private Json parseBody(HTTPServerRequest req) {
  auto raw = req.bodyReader.readAllUTF8();
  if (!raw.length)
    return Json(null);
  return parseJSON(raw);
}

private Json errorPayload(string msg, string details = "") {
  Json payload = Json.emptyObject;
  payload["error"] = msg;
  if (details.length)
    payload["details"] = details;
  return payload;
}

private SoftwareTranslateRequest parseSoftwareRequest(Json data) {
  SoftwareTranslateRequest req;
  req.sourceLanguage = data["sourceLanguage"].getString;
  req.targetLanguage = data["targetLanguage"].getString;
  req.provider = data["provider"].isNull ? "sap-nmt" : data["provider"].getString;
  req.domain = data["domain"].isNull ? "sap" : data["domain"].getString;

  foreach (item; data["texts"].array) {
    req.texts ~= item.getString;
  }

  return req;
}

private DocumentTranslateSyncRequest parseDocumentSyncRequest(Json json) {
  return DocumentTranslateSyncRequest(
    json.getString("sourceLanguage"),
    json.getString("targetLanguage"),
    json.getString("fileName"),
    json.getString("content"),
    json["provider"].isNull ? "sap-nmt" : json.getString("provider")
  );
}

private DocumentTranslateAsyncRequest parseDocumentAsyncRequest(Json json) {
  return DocumentTranslateAsyncRequest(
    json.getString("sourceLanguage"),
    json.getString("targetLanguage"),
    json.getString("fileName"),
    json.getString("content"),
    json["provider"].isNull ? "sap-nmt" : json.getString("provider")
  );
}

private Json asJson(SoftwareTranslateResponse resp) {
  auto items = resp.translatedTexts.map!(text => Json(text)).array;

  return Json.emptyObject
    .set("sourceLanguage", resp.sourceLanguage)
    .set("targetLanguage", resp.targetLanguage)
    .set("provider", resp.provider)
    .set("qualityIndex", resp.qualityIndex)
    .set("qualityHint", resp.qualityHint)
    .set("timestamp", ts(resp.timestamp))
    .set("translatedTexts", items);
}

private Json asJson(DocumentTranslateSyncResponse resp) {
  return Json.emptyObject
    .set("requestId", resp.requestId)
    .set("provider", resp.provider)
    .set("targetLanguage", resp.targetLanguage)
    .set("translatedContent", resp.translatedContent)
    .set("timestamp", ts(resp.timestamp));
}

private Json asJson(AsyncJob job) {
  return Json.emptyObject
  .set("id", job.id)
  .set("status", cast(string)job.status)
  .set("provider", job.provider)
  .set("sourceLanguage", job.sourceLanguage)
  .set("targetLanguage", job.targetLanguage)
  .set("translatedContent", job.translatedContent)
  .set("error", job.error)
  .set("createdAt", ts(job.createdAt))
  .set("updatedAt", ts(job.updatedAt));
}

private Json asJson(Project p) {
  Json[] langs;
  foreach (lang; p.targetLanguages)
    langs ~= Json(lang);

  return Json.emptyObject
  .set("id", p.id)
  .set("name", p.name)
  .set("kind", p.kind)
  .set("sourceLanguage", p.sourceLanguage)
  .set("createdAt", ts(p.createdAt))
  .set("targetLanguages", langs);
}

private Json asJson(LanguageAsset a) {
  Json[] segs;
  foreach (s; a.segments)
    segs ~= Json(s);

  return Json.emptyObject
  .set("id", a.id)
  .set("name", a.name)
  .set("domain", a.domain)
  .set("sourceLanguage", a.sourceLanguage)
  .set("targetLanguage", a.targetLanguage)
  .set("createdAt", ts(a.createdAt))
  .set("segments", segs);
}

private string landingPage() {
  return q"HTML
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>Translation Hub Service</title>
  <style>
    :root {
      --bg: radial-gradient(circle at 20% 20%, #c8f1ff 0%, #f5f7ff 36%, #f4ffee 100%);
      --ink: #1d2a3a;
      --brand: #0057b8;
      --accent: #0f9d58;
      --card: rgba(255,255,255,0.78);
      --line: #c8d5ea;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: "IBM Plex Sans", "Source Sans Pro", sans-serif;
      color: var(--ink);
      background: var(--bg);
      min-height: 100vh;
    }
    main {
      max-width: 980px;
      margin: 2rem auto;
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: 18px;
      padding: 1.5rem;
      backdrop-filter: blur(4px);
    }
    h1 { margin-top: 0; letter-spacing: 0.02em; }
    .grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1rem;
    }
    section {
      border: 1px solid var(--line);
      border-radius: 12px;
      padding: 1rem;
      background: #fff;
      animation: rise 500ms ease both;
    }
    section:nth-child(2) { animation-delay: 120ms; }
    section:nth-child(3) { animation-delay: 240ms; }
    code {
      background: #eef4ff;
      padding: 0.1rem 0.35rem;
      border-radius: 6px;
      color: var(--brand);
    }
    @keyframes rise {
      from { transform: translateY(6px); opacity: 0; }
      to { transform: translateY(0); opacity: 1; }
    }
  </style>
</head>
<body>
  <main>
    <h1>Translation Hub API</h1>
    <p>AI-powered software and document translation service implemented with D and vibe.d.</p>
    <div class="grid">
      <section>
        <h3>Software Translation</h3>
        <p><code>POST /api/v1/software/translate</code></p>
        <p>Providers: <code>sap-nmt</code>, <code>llm</code>, <code>mltr</code>, <code>company-mltr</code>.</p>
      </section>
      <section>
        <h3>Document Translation</h3>
        <p><code>POST /api/v1/document/translate/sync</code></p>
        <p><code>POST /api/v1/document/translate/async</code> + <code>GET /api/v1/document/jobs/status?jobId=...</code></p>
      </section>
      <section>
        <h3>Workflow Assets</h3>
        <p>Project management, language data integration, quality estimation and provider discovery APIs.</p>
      </section>
    </div>
  </main>
</body>
</html>
HTML";
}
version (unittest) {
} else {
  void main() {
  auto cfg = loadConfig();

  auto providerRegistry = new ProviderRegistry();
  auto translationService = new TranslationService(providerRegistry);
  auto asyncJobs = new AsyncJobStore(translationService);
  auto projects = new ProjectStore();
  auto languageAssets = new LanguageAssetStore();

  auto router = new URLRouter();

  router.get("/", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    res.contentType = "text/html; charset=utf-8";
    res.writeBody(landingPage());
  });

  router.get("/health", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    Json payload = Json.emptyObject
    .set("status", "ok")
    .set("service", cfg.serviceName)
    .set("version", "0.1.0");

    writeJson(res, payload);
  });

  router.get("/api/v1/providers", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    Json payload = Json.emptyObject;
    Json[] names;
    foreach (n; providerRegistry.names())
      names ~= Json(n);
    payload["providers"] = names;
    payload["supportedLanguages"] = cfg.supportedLanguages.map!(l => Json(l)).array;
    writeJson(res, payload);
  });

  router.post("/api/v1/software/translate", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto data = parseBody(req);
      auto request = parseSoftwareRequest(data);
      if (request.texts.length == 0) {
        writeJson(res, errorPayload("invalid_request", "texts must not be empty"), 400);
        return;
      }
      auto response = translationService.translateSoftware(request);
      writeJson(res, asJson(response));
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.post("/api/v1/quality/estimate", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto data = parseBody(req);
      string[] texts;
      foreach (item; data["texts"].array)
        texts ~= item.getString;
      auto provider = data["provider"].isNull ? "sap-nmt" : data["provider"].getString;
      auto target = data["targetLanguage"].isNull ? "de"
        : data["targetLanguage"].getString;

      Json payload = Json.emptyObject;
      payload["qualityIndex"] = translationService.estimateQuality(texts, target, provider);
      writeJson(res, payload);
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.post("/api/v1/document/translate/sync", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto body = parseBody(req);
      auto request = parseDocumentSyncRequest(body);
      auto response = translationService.translateDocumentSync(request);
      writeJson(res, asJson(response));
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.post("/api/v1/document/translate/async", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto data = parseBody(req);
      auto request = parseDocumentAsyncRequest(data);
      auto jobId = asyncJobs.enqueue(request);
      Json payload = Json.emptyObject
        .set("jobId", jobId)
        .set("status", "queued");

      writeJson(res, payload, 202);
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.get("/api/v1/document/jobs/status", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    auto jobId = req.query.get("jobId", "");
    if (!jobId.length) {
      writeJson(res, errorPayload("invalid_request", "jobId query parameter is required"), 400);
      return;
    }
    auto job = asyncJobs.get(jobId);
    writeJson(res, asJson(job));
  });

  router.post("/api/v1/projects", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto bodyData = parseBody(req);
      auto name = bodyData["name"].getString;
      auto kind = bodyData["kind"].getString.toLower();
      auto sourceLanguage = bodyData["sourceLanguage"].getString;
      string[] targetLanguages;
      foreach (item; bodyData["targetLanguages"].array)
        targetLanguages ~= item.getString;

      auto p = projects.create(name, kind, sourceLanguage, targetLanguages);
      writeJson(res, asJson(p), 201);
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.get("/api/v1/projects", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    Json[] items = projects.list().map!(p => asJson(p)).array;

    Json payload = Json.emptyObject
      .set("projects", items);

    writeJson(res, payload);
  });

  router.post("/api/v1/language-data", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    try {
      auto bodyData = parseBody(req);
      auto name = bodyData["name"].getString;
      auto domain = bodyData["domain"].getString;
      auto source = bodyData["sourceLanguage"].getString;
      auto target = bodyData["targetLanguage"].getString;
      string[] segments;
      foreach (item; bodyData["segments"].array)
        segments ~= item.getString;

      auto asset = languageAssets.create(name, domain, source, target, segments);
      writeJson(res, asJson(asset), 201);
    } catch (Exception ex) {
      writeJson(res, errorPayload("invalid_request", ex.msg), 400);
    }
  });

  router.get("/api/v1/language-data", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
    Json[] items = languageAssets.list().map!(asset => asset.toJson).array;

    Json payload = Json.emptyObject
      .set("assets", items);

    writeJson(res, payload);
  });

  auto settings = new HTTPServerSettings;
  settings.bindAddresses = [cfg.bindAddress];
  settings.port = cfg.port;

  logInfo("Starting %s on %s:%s", cfg.serviceName, cfg.bindAddress, cfg.port);
  listenHTTP(settings, router);
  runEventLoop();
}
