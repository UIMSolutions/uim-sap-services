module models;

import std.datetime : Clock, SysTime;

class SoftwareTranslateRequest  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string[] texts;
    string provider; // sap-nmt | llm | mltr | company-mltr
    string domain;   // sap | generic | custom
}

class SoftwareTranslateResponse : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string provider;
    string[] translatedTexts;
    int qualityIndex;
    string qualityHint;
    SysTime timestamp;
}

UUID DocumentTranslateSyncRequest : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    string sourceLanguage;
    string targetLanguage;
    string fileName;
    string content;
    string provider; // sap-nmt | llm
}

class DocumentTranslateSyncResponse  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    UUID requestId;
    string provider;
    string targetLanguage;
    string translatedContent;
    SysTime timestamp;
}

class DocumentTranslateAsyncRequest  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

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

class AsyncJob  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

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

class Project  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    UUID id;
    string name;
    string kind; // file | git | abap
    string sourceLanguage;
    string[] targetLanguages;
    SysTime createdAt;
}

class LanguageAsset  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    UUID id;
    string name;
    string domain;
    string sourceLanguage;
    string targetLanguage;
    string[] segments;
    SysTime createdAt;
}

struct ApiError  : SAPObject {
mixin(SAPObjectTemplate!SoftwareTranslateResponse);

    string error;
    string details;
}

SysTime nowUtc() {
    return Clock.currTime();
}
