/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.obs.models.replication;

import std.datetime : Clock, SysTime;

import vibe.data.json : Json;

import uim.sap.obs.enumerations;

@safe:

/// Cross-region replication configuration for a bucket
struct OBSReplicationConfig {
  UUID configId;
  UUID sourceBucketId;
  string destinationRegion;
  OBSProvider destinationProvider;
  OBSReplicationStatus status = OBSReplicationStatus.pending;
  string prefix; // optional key prefix filter
  bool replicateDeletes = true;
  SysTime createdAt;
  SysTime updatedAt;

  override Json toJson() {
    return super.toJson
      .set("config_id", configId)
      .set("source_bucket_id", sourceBucketId)
      .set("destination_region", destinationRegion)
      .set("destination_provider", cast(string)destinationProvider)
      .set("status", cast(string)status)
      .set("prefix", prefix)
      .set("replicate_deletes", replicateDeletes)
      .set("created_at", createdAt.toISOExtString())
      .set("updated_at", updatedAt.toISOExtString());
  }

  OBSReplicationConfig replicationFromJson(UUID configId, UUID bucketId, Json req) {
  OBSReplicationConfig c = new OBSReplicationConfig(req);
  c.configId = configId;
  c.sourceBucketId = bucketId;
  c.createdAt = Clock.currTime();
  c.updatedAt = c.createdAt;

  if ("destination_region" in req && req["destination_region"].isString)
    c.destinationRegion = req["destination_region"].get!string;
  if ("destination_provider" in req && req["destination_provider"].isString) {
    switch (req["destination_provider"].get!string) {
    case "azure_blob":
      c.destinationProvider = OBSProvider.azureBlob;
      break;
    case "gcp_storage":
      c.destinationProvider = OBSProvider.gcpStorage;
      break;
    default:
      c.destinationProvider = OBSProvider.awsS3;
      break;
    }
  }
  if ("prefix" in req && req["prefix"].isString)
    c.prefix = req["prefix"].get!string;
  if ("replicate_deletes" in req && req["replicate_deletes"].isBoolean)
    c.replicateDeletes = req["replicate_deletes"].get!bool;
  return c;
}
}


