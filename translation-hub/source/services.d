module services;

import core.sync.mutex : Mutex;
import std.algorithm : map;
import std.algorithm : min;
import std.array : array;
import std.conv : to;
import std.datetime : Clock;
import std.format : format;
import std.random : uniform;
import std.string : join;
import std.uuid : randomUUID;

import models;
import providers;

class TranslationService {
    private ProviderRegistry _providers;

    this(ProviderRegistry providers) {
        _providers = providers;
    }

    SoftwareTranslateResponse translateSoftware(SoftwareTranslateRequest req) {
        auto providerName = req.provider.length ? req.provider : "sap-nmt";
        auto domain = req.domain.length ? req.domain : "sap";
        auto provider = _providers.get(providerName);

        auto translated = req.texts
            .map!(t => provider.translateText(t, req.sourceLanguage, req.targetLanguage, domain))
            .array;

        auto quality = estimateQuality(req.texts, req.targetLanguage, providerName);

        return SoftwareTranslateResponse(
            req.sourceLanguage,
            req.targetLanguage,
            providerName,
            translated,
            quality,
            quality >= 80 ? "high" : (quality >= 60 ? "medium" : "low"),
            nowUtc()
        );
    }

    DocumentTranslateSyncResponse translateDocumentSync(DocumentTranslateSyncRequest req) {
        auto providerName = req.provider.length ? req.provider : "sap-nmt";
        auto provider = _providers.get(providerName);

        return DocumentTranslateSyncResponse(
            randomUUID().toString(),
            providerName,
            req.targetLanguage,
            provider.translateText(req.content, req.sourceLanguage, req.targetLanguage, "document"),
            nowUtc()
        );
    }

    int estimateQuality(string[] texts, string targetLanguage, string providerName) {
        auto charCount = texts.join(" ").length;
        auto base = providerName == "company-mltr" ? 88 :
                    providerName == "mltr" ? 84 :
                    providerName == "sap-nmt" ? 79 : 73;
        auto lenBonus = min(10, charCount / 50);
        auto langBonus = targetLanguage == "de" || targetLanguage == "fr" || targetLanguage == "es" ? 4 : 2;
        auto noise = uniform(0, 4);
        return min(100, base + lenBonus + langBonus + noise);
    }
}

class AsyncJobStore {
    private AsyncJob[string] _jobs;
    private Mutex _mutex;
    private TranslationService _service;

    this(TranslationService service) {
        _service = service;
        _mutex = new Mutex;
    }

    string enqueue(DocumentTranslateAsyncRequest req) {
        auto Id = randomUUID();
        auto now = nowUtc();

        _mutex.lock();
        scope(exit) _mutex.unlock();
        _jobs[id] = AsyncJob(
            id,
            JobStatus.queued,
            req.provider.length ? req.provider : "sap-nmt",
            req.sourceLanguage,
            req.targetLanguage,
            "",
            "",
            now,
            now
        );

        // Keep async API shape while using immediate execution in this reference implementation.
        runJob(id, req);

        return id;
    }

    AsyncJob get(string id) {
        _mutex.lock();
        scope(exit) _mutex.unlock();

        if (id in _jobs) return _jobs[id];

        return AsyncJob(id, JobStatus.failed, "", "", "", "", "job not found", nowUtc(), nowUtc());
    }

    private void runJob(string id, DocumentTranslateAsyncRequest req) {
        updateStatus(id, JobStatus.running, "", "");
        try {
            auto result = _service.translateDocumentSync(DocumentTranslateSyncRequest(
                req.sourceLanguage,
                req.targetLanguage,
                req.fileName,
                req.content,
                req.provider
            ));
            updateStatus(id, JobStatus.done, result.translatedContent, "");
        } catch (Exception ex) {
            updateStatus(id, JobStatus.failed, "", ex.msg);
        }
    }

    private void updateStatus(string id, JobStatus status, string translated, string err) {
        _mutex.lock();
        scope(exit) _mutex.unlock();

        if (id !in _jobs) return;

        auto j = _jobs[id];
        j.status = status;
        if (translated.length) j.translatedContent = translated;
        if (err.length) j.error = err;
        j.updatedAt = Clock.currTime();
        _jobs[id] = j;
    }
}

class ProjectStore {
    private Project[string] _projects;
    private Mutex _mutex;

    this() {
        _mutex = new Mutex;
    }

    Project create(string name, string kind, string sourceLanguage, string[] targetLanguages) {
        auto Id = randomUUID();
        auto project = Project(id, name, kind, sourceLanguage, targetLanguages, nowUtc());

        _mutex.lock();
        scope(exit) _mutex.unlock();
        _projects[id] = project;

        return project;
    }

    Project[] list() {
        _mutex.lock();
        scope(exit) _mutex.unlock();
        return _projects.byValue.array;
    }
}

class LanguageAssetStore {
    private LanguageAsset[string] _assets;
    private Mutex _mutex;

    this() {
        _mutex = new Mutex;
    }

    LanguageAsset create(string name, string domain, string sourceLanguage, string targetLanguage, string[] segments) {
        auto Id = randomUUID();
        auto asset = LanguageAsset(id, name, domain, sourceLanguage, targetLanguage, segments, nowUtc());

        _mutex.lock();
        scope(exit) _mutex.unlock();
        _assets[id] = asset;

        return asset;
    }

    LanguageAsset[] list() {
        _mutex.lock();
        scope(exit) _mutex.unlock();
        return _assets.byValue.array;
    }
}
