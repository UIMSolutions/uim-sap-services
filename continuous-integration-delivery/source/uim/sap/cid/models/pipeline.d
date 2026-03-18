module uim.sap.cid.models.pipeline;

// ---------------------------------------------------------------------------
// CIDPipeline – a CI/CD pipeline configuration
// ---------------------------------------------------------------------------
class CIDPipeline : SAPTenantObject {
  mixin(SAPObjectTemplate!CIDPipeline);

  UUID pipelineId;
  string name;
  string description;
  /// Connected repository
  UUID repositoryId;
  /// Branch to build (overrides repo default if set)
  string branch;
  /// Pipeline type: "sap-cloud-sdk" | "sap-fiori" | "sap-integration" |
  ///                "sap-abap" | "custom"
  string pipelineType;
  /// Stages to run (e.g. ["build","test","deploy"])
  string[] stages;
  /// Deploy target runtime: "cloud-foundry" | "abap" | "neo" | "kyma"
  string deployTarget;
  /// Deploy endpoint / landscape URL
  string deployEndpoint;
  /// Credential for deploy (optional)
  UUID deployCredentialId;
  /// Whether the pipeline triggers automatically on push
  bool autoTrigger;
  bool active;

  override Json toJson() {
    Json stArr = stages.map!(stage => stage.toJson).array.toJson;

    return super.toJson()
      .set("pipeline_id", pipelineId)
      .set("name", name)
      .set("description", description)
      .set("repository_id", repositoryId)
      .set("branch", branch)
      .set("pipeline_type", pipelineType)
      .set("stages", stArr)
      .set("deploy_target", deployTarget)
      .set("deploy_endpoint", deployEndpoint)
      .set("deploy_credential_id", deployCredentialId)
      .set("auto_trigger", autoTrigger)
      .set("active", active);
  }
}
