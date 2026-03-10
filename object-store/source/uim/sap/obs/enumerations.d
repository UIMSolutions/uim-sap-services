module uim.sap.obs.enumerations;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

/// Cloud storage provider
enum OBSProvider : string {
    awsS3 = "aws-s3",
    azureBlob = "azure-blob",
    gcpStorage = "gcp-storage",
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
    archived = "archived",
    deleted = "deleted",
}

/// Bucket access level
enum OBSAccessLevel : string {
    private_ = "private",
    readOnly = "read-only",
    readWrite = "read-write",
}

/// Storage class / tier
enum OBSStorageClass : string {
    standard = "standard",
    infrequentAccess = "infrequent-access",
    archive = "archive",
    coldline = "coldline",
}

/// Object encryption type
enum OBSEncryption : string {
    none = "none",
    sseS3 = "sse-s3",
    sseKms = "sse-kms",
    sseC = "sse-c",
}

/// Credential status
enum OBSCredentialStatus : string {
    active = "active",
    expired = "expired",
    revoked = "revoked",
}

/// Replication status
enum OBSReplicationStatus : string {
    enabled = "enabled",
    disabled = "disabled",
    pending = "pending",
}

/// Lifecycle action
enum OBSLifecycleAction : string {
    transition = "transition",
    expiration = "expiration",
    abortMultipart = "abort-multipart",
}
