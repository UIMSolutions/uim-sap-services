module uim.sap.kym.enumerations;

import uim.sap.kym;

mixin(ShowModule!());

@safe:

/// Runtime of a serverless function
enum KYMFunctionRuntime : string {
    NODEJS18 = "nodejs18",
    NODEJS20 = "nodejs20",
    PYTHON39 = "python39",
    PYTHON312 = "python312",
    DLANG = "dlang"
}

/// Status of a deployed resource
enum KYMResourceStatus : string {
    PENDING = "pending",
    DEPLOYING = "deploying",
    RUNNING = "running",
    STOPPED = "stopped",
    FAILED = "failed",
    DELETING = "deleting"
}

/// Type of event trigger
enum KYMTriggerType : string {
    HTTP = "http",
    EVENT = "event",
    TIMER = "timer"
}

/// Microservice protocol
enum KYMProtocol : string {
    HTTP = "http",
    GRPC = "grpc",
    TCP = "tcp"
}

/// API rule access strategy
enum KYMAccessStrategy : string {
    NO_AUTH = "no_auth",
    JWT = "jwt",
    OAUTH2 = "oauth2"
}

/// Scaling policy
enum KYMScalePolicy : string {
    MANUAL = "manual",
    AUTO_CPU = "auto_cpu",
    AUTO_MEMORY = "auto_memory",
    AUTO_REQUESTS = "auto_requests",
    EVENT_DRIVEN = "event_driven"
}

KYMFunctionRuntime parseRuntime(string value) {
    switch (value) {
        case "nodejs18": return KYMFunctionRuntime.NODEJS18;
        case "nodejs20": return KYMFunctionRuntime.NODEJS20;
        case "python39": return KYMFunctionRuntime.PYTHON39;
        case "python312": return KYMFunctionRuntime.PYTHON312;
        case "dlang": return KYMFunctionRuntime.DLANG;
        default: return KYMFunctionRuntime.NODEJS20;
    }
}

KYMResourceStatus parseStatus(string value) {
    switch (value) {
        case "pending": return KYMResourceStatus.PENDING;
        case "deploying": return KYMResourceStatus.DEPLOYING;
        case "running": return KYMResourceStatus.RUNNING;
        case "stopped": return KYMResourceStatus.STOPPED;
        case "failed": return KYMResourceStatus.FAILED;
        case "deleting": return KYMResourceStatus.DELETING;
        default: return KYMResourceStatus.PENDING;
    }
}

KYMTriggerType parseTriggerType(string value) {
    switch (value) {
        case "http": return KYMTriggerType.HTTP;
        case "event": return KYMTriggerType.EVENT;
        case "timer": return KYMTriggerType.TIMER;
        default: return KYMTriggerType.HTTP;
    }
}

KYMAccessStrategy parseAccessStrategy(string value) {
    switch (value) {
        case "no_auth": return KYMAccessStrategy.NO_AUTH;
        case "jwt": return KYMAccessStrategy.JWT;
        case "oauth2": return KYMAccessStrategy.OAUTH2;
        default: return KYMAccessStrategy.NO_AUTH;
    }
}

KYMScalePolicy parseScalePolicy(string value) {
    switch (value) {
        case "manual": return KYMScalePolicy.MANUAL;
        case "auto_cpu": return KYMScalePolicy.AUTO_CPU;
        case "auto_memory": return KYMScalePolicy.AUTO_MEMORY;
        case "auto_requests": return KYMScalePolicy.AUTO_REQUESTS;
        case "event_driven": return KYMScalePolicy.EVENT_DRIVEN;
        default: return KYMScalePolicy.MANUAL;
    }
}
