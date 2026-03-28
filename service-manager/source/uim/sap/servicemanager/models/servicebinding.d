module uim.sap.servicemanager.models.servicebinding;

/**
  * SVMServiceBinding represents a service binding in the Service Manager.
  *
  * It contains information about the binding, such as its ID, associated service instance, environment, name, and credentials reference.
  * The toJson method converts the service binding object into a JSON representation for easy serialization and communication with other components.
  * For more information on service bindings and their management, refer to the SAP Service Manager documentation.
  * Fields:
  * - tenantId: The ID of the tenant that owns this service binding.
  * - bindingId: Unique identifier for the service binding.
  * - instanceId: The ID of the service instance this binding is associated with.
  * - environmentId: The ID of the environment where the service instance is provisioned.
  * - name: The name of the service binding.
  * - credentialsRef: A reference to the credentials associated with this binding, which can be used to retrieve the actual credentials from a secure store.
  * Methods:
  * - toJson(): Converts the service binding object into a JSON representation for API responses or storage.
  * For more information on service bindings and their management, refer to the SAP Service Manager documentation.
  * Statuses:
  * - active: The service binding is active and can be used to access the associated service instance.
  * - inactive: The service binding is inactive and cannot be used to access the associated service instance.
  * - deleted: The service binding has been deleted and is no longer available.
 */
class SVMServiceBinding : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!SVMServiceBinding);

  UUID bindingId;
  UUID instanceId;
  UUID environmentId;
  string name;
  string credentialsRef;

  override Json toJson()  {
    return super.toJson
      .set("binding_id", bindingId)
      .set("instance_id", instanceId)
      .set("name", name)
      .set("environment_id", environmentId)
      .set("credentials_ref", credentialsRef);
  }
}
