module uim.sap.obs.enumerations;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

/// Supported IaaS storage providers
enum OBSProvider : string {
    aws = "aws",
    azure = "azure",
    gcp = "gcp",
}

/// Bucket status
enum OBSBucketStatus : string {
    active = "active",
    suspended = "suspended",
    deleted = "deleted",
}

/// Object status
enum OBSObjectStatus : string {
    active = "active",
    deleted = "deleted",
    archived = "archived",
}

/// Storage class / tier
enum OBSStorageClass : string {
    standard = "STANDARD",
    nearline = "NEARLINE",
    coldline = "COLDLINE",
    archive = "ARCHIVE",
}

/// Access level for buckets
enum OBSAccessLevel : string {
    private_ = "private",
    readOnly = "read-only",
    readWrite = "read-write",
}

/// Credential status
enum OBSCredentialStatus : string {
    active = "active",
    expired = "expired",
    revoked = "revoked",
}

/// Replication mode
enum OBSReplicationMode : string {
    none = "none",
    singleRegion = "single-region",
    multiRegion = "multi-region",
}
