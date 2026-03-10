module uim.sap.obs.enumerations;

import uim.sap.obs;

mixin(ShowModule!());

@safe:

/// Cloud provider / IaaS layer
enum OBSProvider : string {
    awsS3 = "aws_s3",
    azureBlob = "azure_blob",
    gcpStorage = "gcp_storage",
}

/// Bucket status
enum OBSBucketStatus : string {
    active = "active",
    suspended = "suspended",
    deleted = "deleted",
}

/// Bucket access level
enum OBSAccessLevel : string {
    private_ = "private",
    publicRead = "public_read",
    publicReadWrite = "public_read_write",
}

/// Storage class
enum OBSStorageClass : string {
    standard = "standard",
    nearline = "nearline",       // infrequent access
    coldline = "coldline",       // archival
    archive = "archive",         // deep archive
}

/// Object status
enum OBSObjectStatus : string {
    active = "active",
    deleted = "deleted",
    archived = "archived",
}

/// Replication status
enum OBSReplicationStatus : string {
    complete = "complete",
    pending = "pending",
    failed = "failed",
}

/// Credential type
enum OBSCredentialType : string {
    accessKey = "access_key",
    sasToken = "sas_token",
    signedUrl = "signed_url",
}

/// Multipart upload status
enum OBSUploadStatus : string {
    initiated = "initiated",
    inProgress = "in_progress",
    completed = "completed",
    aborted = "aborted",
}

/// Lifecycle action
enum OBSLifecycleAction : string {
    transition = "transition",
    expiration = "expiration",
}
