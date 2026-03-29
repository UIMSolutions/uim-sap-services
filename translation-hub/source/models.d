module models;

import std.datetime : Clock, SysTime;

class SoftwareTranslateRequest  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string[] texts;
    string provider; // sap-nmt | llm | mltr | company-mltr
    string domain;   // sap | generic | custom
}

class SoftwareTranslateResponse : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string provider;
    string[] translatedTexts;
    int qualityIndex;
    string qualityHint;
    SysTime timestamp;
}

UUID DocumentTranslateSyncRequest : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string fileName;
    string content;
    string provider; // sap-nmt | llm
}

class DocumentTranslateSyncResponse  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    UUID requestId;
    string provider;
    string targetLanguage;
    string translatedContent;
    SysTime timestamp;
}

class DocumentTranslateAsyncRequest  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

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

class AsyncJob  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    UUID id;
    JobStatus status;
    string provider;
    string sourceLanguage;
    string targetLanguage;
    string translatedContent;
    string error;
    SysTime createdAt;
    SysTime updatedAt;
}

class Project  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    UUID id;
    string name;
    string kind; // file | git | abap
    string sourceLanguage;
    string[] targetLanguages;
    SysTime createdAt;
}

class LanguageAsset  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    UUID id;
    string name;
    string domain;
    string sourceLanguage;
    string targetLanguage;
    string[] segments;
    SysTime createdAt;
}

struct ApiError  : SAPEntity {
mixin(SAPEntityTemplate!SoftwareTranslateResponse);

    string error;
    string details;
}

SysTime nowUtc() {
    return Clock.currTime();
}
