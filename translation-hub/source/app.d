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

private void writeJson(HTTPServerResponse res, JSONValue payload, int code = 200) {
    res.statusCode = code;
    res.contentType = "application/json; charset=utf-8";
    res.writeBody(payload.toString());
}

private JSONValue parseBody(HTTPServerRequest req) {
    auto raw = req.bodyReader.readAllUTF8();
    if (!raw.length) return JSONValue(null);
    return parseJSON(raw);
}

private JSONValue errorPayload(string msg, string details = "") {
    JSONValue payload;
    payload["error"] = msg;
    if (details.length) payload["details"] = details;
    return payload;
}

private SoftwareTranslateRequest parseSoftwareRequest(JSONValue body) {
    SoftwareTranslateRequest req;
    req.sourceLanguage = body["sourceLanguage"].str;
    req.targetLanguage = body["targetLanguage"].str;
    req.provider = body["provider"].type == JSONType.null_ ? "sap-nmt" : body["provider"].str;
    req.domain = body["domain"].type == JSONType.null_ ? "sap" : body["domain"].str;

    foreach (item; body["texts"].array) {
        req.texts ~= item.str;
    }

    return req;
}

private DocumentTranslateSyncRequest parseDocumentSyncRequest(JSONValue body) {
    return DocumentTranslateSyncRequest(
        body["sourceLanguage"].str,
        body["targetLanguage"].str,
        body["fileName"].str,
        body["content"].str,
        body["provider"].type == JSONType.null_ ? "sap-nmt" : body["provider"].str
    );
}

private DocumentTranslateAsyncRequest parseDocumentAsyncRequest(JSONValue body) {
    return DocumentTranslateAsyncRequest(
        body["sourceLanguage"].str,
        body["targetLanguage"].str,
        body["fileName"].str,
        body["content"].str,
        body["provider"].type == JSONType.null_ ? "sap-nmt" : body["provider"].str
    );
}

private JSONValue asJson(SoftwareTranslateResponse resp) {
    JSONValue payload;
    payload["sourceLanguage"] = resp.sourceLanguage;
    payload["targetLanguage"] = resp.targetLanguage;
    payload["provider"] = resp.provider;
    payload["qualityIndex"] = resp.qualityIndex;
    payload["qualityHint"] = resp.qualityHint;
    payload["timestamp"] = ts(resp.timestamp);

    JSONValue[] items;
    foreach (text; resp.translatedTexts) {
        items ~= JSONValue(text);
    }
    payload["translatedTexts"] = items;
    return payload;
}

private JSONValue asJson(DocumentTranslateSyncResponse resp) {
    JSONValue payload;
    payload["requestId"] = resp.requestId;
    payload["provider"] = resp.provider;
    payload["targetLanguage"] = resp.targetLanguage;
    payload["translatedContent"] = resp.translatedContent;
    payload["timestamp"] = ts(resp.timestamp);
    return payload;
}

private JSONValue asJson(AsyncJob job) {
    JSONValue payload;
    payload["id"] = job.id;
    payload["status"] = cast(string)job.status;
    payload["provider"] = job.provider;
    payload["sourceLanguage"] = job.sourceLanguage;
    payload["targetLanguage"] = job.targetLanguage;
    payload["translatedContent"] = job.translatedContent;
    payload["error"] = job.error;
    payload["createdAt"] = ts(job.createdAt);
    payload["updatedAt"] = ts(job.updatedAt);
    return payload;
}

private JSONValue asJson(Project p) {
    JSONValue payload;
    payload["id"] = p.id;
    payload["name"] = p.name;
    payload["kind"] = p.kind;
    payload["sourceLanguage"] = p.sourceLanguage;
    payload["createdAt"] = ts(p.createdAt);

    JSONValue[] langs;
    foreach (lang; p.targetLanguages) langs ~= JSONValue(lang);
    payload["targetLanguages"] = langs;
    return payload;
}

private JSONValue asJson(LanguageAsset a) {
    JSONValue payload;
    payload["id"] = a.id;
    payload["name"] = a.name;
    payload["domain"] = a.domain;
    payload["sourceLanguage"] = a.sourceLanguage;
    payload["targetLanguage"] = a.targetLanguage;
    payload["createdAt"] = ts(a.createdAt);

    JSONValue[] segs;
    foreach (s; a.segments) segs ~= JSONValue(s);
    payload["segments"] = segs;
    return payload;
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
        JSONValue payload;
        payload["status"] = "ok";
        payload["service"] = cfg.serviceName;
        payload["version"] = "0.1.0";
        writeJson(res, payload);
    });

    router.get("/api/v1/providers", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
        JSONValue payload;
        JSONValue[] names;
        foreach (n; providerRegistry.names()) names ~= JSONValue(n);
        payload["providers"] = names;
        payload["supportedLanguages"] = cfg.supportedLanguages.map!(l => JSONValue(l)).array;
        writeJson(res, payload);
    });

    router.post("/api/v1/software/translate", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
        try {
            auto body = parseBody(req);
            auto request = parseSoftwareRequest(body);
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
            auto body = parseBody(req);
            string[] texts;
            foreach (item; body["texts"].array) texts ~= item.str;
            auto provider = body["provider"].type == JSONType.null_ ? "sap-nmt" : body["provider"].str;
            auto target = body["targetLanguage"].type == JSONType.null_ ? "de" : body["targetLanguage"].str;

            JSONValue payload;
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
            auto body = parseBody(req);
            auto request = parseDocumentAsyncRequest(body);
            auto jobId = asyncJobs.enqueue(request);
            JSONValue payload;
            payload["jobId"] = jobId;
            payload["status"] = "queued";
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
            auto body = parseBody(req);
            auto name = body["name"].str;
            auto kind = body["kind"].str.toLower();
            auto sourceLanguage = body["sourceLanguage"].str;
            string[] targetLanguages;
            foreach (item; body["targetLanguages"].array) targetLanguages ~= item.str;

            auto p = projects.create(name, kind, sourceLanguage, targetLanguages);
            writeJson(res, asJson(p), 201);
        } catch (Exception ex) {
            writeJson(res, errorPayload("invalid_request", ex.msg), 400);
        }
    });

    router.get("/api/v1/projects", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
        JSONValue payload;
        JSONValue[] items;
        foreach (p; projects.list()) items ~= asJson(p);
        payload["projects"] = items;
        writeJson(res, payload);
    });

    router.post("/api/v1/language-data", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
        try {
            auto body = parseBody(req);
            auto name = body["name"].str;
            auto domain = body["domain"].str;
            auto source = body["sourceLanguage"].str;
            auto target = body["targetLanguage"].str;
            string[] segments;
            foreach (item; body["segments"].array) segments ~= item.str;

            auto asset = languageAssets.create(name, domain, source, target, segments);
            writeJson(res, asJson(asset), 201);
        } catch (Exception ex) {
            writeJson(res, errorPayload("invalid_request", ex.msg), 400);
        }
    });

    router.get("/api/v1/language-data", (HTTPServerRequest req, HTTPServerResponse res) @trusted {
        JSONValue payload;
        JSONValue[] items;
        foreach (asset; languageAssets.list()) items ~= asJson(asset);
        payload["assets"] = items;
        writeJson(res, payload);
    });

    auto settings = new HTTPServerSettings;
    settings.bindAddresses = [cfg.bindAddress];
    settings.port = cfg.port;

    logInfo("Starting %s on %s:%s", cfg.serviceName, cfg.bindAddress, cfg.port);
    listenHTTP(settings, router);
    runEventLoop();
}
