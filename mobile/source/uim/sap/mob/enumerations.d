module uim.sap.mob.enumerations;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

/// Application types supported by Mobile Services
enum MOBAppType : string {
    NATIVE = "native",
    CROSS_PLATFORM = "cross_platform",
    WEB = "web",
    MDK = "mdk"
}

/// Target platform
enum MOBPlatform : string {
    IOS = "ios",
    ANDROID = "android",
    WEB = "web",
    CROSS_PLATFORM = "cross_platform"
}

/// Authentication type for security policies
enum MOBAuthType : string {
    BASIC = "basic",
    OAUTH2 = "oauth2",
    SAML = "saml",
    X509 = "x509",
    BIOMETRIC = "biometric"
}

/// User connection status
enum MOBConnectionStatus : string {
    ACTIVE = "active",
    LOCKED = "locked",
    WIPED = "wiped",
    DELETED = "deleted"
}

/// Push notification provider
enum MOBPushProvider : string {
    APNS = "apns",
    FCM = "fcm",
    WNS = "wns"
}

/// Application lifecycle status
enum MOBAppStatus : string {
    DRAFT = "draft",
    ACTIVE = "active",
    SUSPENDED = "suspended",
    ARCHIVED = "archived"
}

/// SDK type
enum MOBSdkType : string {
    MDK = "mdk",
    IOS = "ios",
    ANDROID = "android"
}

/// App version status
enum MOBVersionStatus : string {
    DRAFT = "draft",
    ACTIVE = "active",
    DEPRECATED = "deprecated",
    RETIRED = "retired"
}

/// Offline sync strategy
enum MOBSyncStrategy : string {
    FULL = "full",
    DELTA = "delta",
    ON_DEMAND = "on_demand"
}

/// Push notification priority
enum MOBPushPriority : string {
    LOW = "low",
    NORMAL = "normal",
    HIGH = "high",
    CRITICAL = "critical"
}

MOBAppType parseAppType(string s) {
    switch (s) {
        case "native": return MOBAppType.NATIVE;
        case "cross_platform": return MOBAppType.CROSS_PLATFORM;
        case "web": return MOBAppType.WEB;
        case "mdk": return MOBAppType.MDK;
        default: return MOBAppType.NATIVE;
    }
}

MOBPlatform parsePlatform(string s) {
    switch (s) {
        case "ios": return MOBPlatform.IOS;
        case "android": return MOBPlatform.ANDROID;
        case "web": return MOBPlatform.WEB;
        case "cross_platform": return MOBPlatform.CROSS_PLATFORM;
        default: return MOBPlatform.IOS;
    }
}

MOBAuthType parseAuthType(string s) {
    switch (s) {
        case "basic": return MOBAuthType.BASIC;
        case "oauth2": return MOBAuthType.OAUTH2;
        case "saml": return MOBAuthType.SAML;
        case "x509": return MOBAuthType.X509;
        case "biometric": return MOBAuthType.BIOMETRIC;
        default: return MOBAuthType.OAUTH2;
    }
}

MOBPushProvider parsePushProvider(string s) {
    switch (s) {
        case "apns": return MOBPushProvider.APNS;
        case "fcm": return MOBPushProvider.FCM;
        case "wns": return MOBPushProvider.WNS;
        default: return MOBPushProvider.FCM;
    }
}

MOBSyncStrategy parseSyncStrategy(string s) {
    switch (s) {
        case "full": return MOBSyncStrategy.FULL;
        case "delta": return MOBSyncStrategy.DELTA;
        case "on_demand": return MOBSyncStrategy.ON_DEMAND;
        default: return MOBSyncStrategy.DELTA;
    }
}

MOBPushPriority parsePushPriority(string s) {
    switch (s) {
        case "low": return MOBPushPriority.LOW;
        case "normal": return MOBPushPriority.NORMAL;
        case "high": return MOBPushPriority.HIGH;
        case "critical": return MOBPushPriority.CRITICAL;
        default: return MOBPushPriority.NORMAL;
    }
}
