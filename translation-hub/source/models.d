module models;

import std.datetime : Clock, SysTime;

struct SoftwareTranslateRequest {
    string sourceLanguage;
    string targetLanguage;
    string[] texts;
    string provider; // sap-nmt | llm | mltr | company-mltr
    string domain;   // sap | generic | custom
}

struct SoftwareTranslateResponse {
    string sourceLanguage;
    string targetLanguage;
    string provider;
    string[] translatedTexts;
    int qualityIndex;
    string qualityHint;
    SysTime timestamp;
}

struct DocumentTranslateSyncRequest {
    string sourceLanguage;
    string targetLanguage;
    string fileName;
    string content;
    string provider; // sap-nmt | llm
}

struct DocumentTranslateSyncResponse {
    string requestId;
    string provider;
    string targetLanguage;
    string translatedContent;
    SysTime timestamp;
}

struct DocumentTranslateAsyncRequest {
    string sourceLanguage;
    string targetLanguage;
    string fileName;
    string content;
    string provider;
}

enum JobStatus : string {
    queued = "queued",
    running = "running",
    done = "done",
    failed = "failed"
}

struct AsyncJob {
    string id;
    JobStatus status;
    string provider;
    string sourceLanguage;
    string targetLanguage;
    string translatedContent;
    string error;
    SysTime createdAt;
    SysTime updatedAt;
}

struct Project {
    string id;
    string name;
    string kind; // file | git | abap
    string sourceLanguage;
    string[] targetLanguages;
    SysTime createdAt;
}

struct LanguageAsset {
    string id;
    string name;
    string domain;
    string sourceLanguage;
    string targetLanguage;
    string[] segments;
    SysTime createdAt;
}

struct ApiError {
    string error;
    string details;
}

SysTime nowUtc() {
    return Clock.currTime();
}
