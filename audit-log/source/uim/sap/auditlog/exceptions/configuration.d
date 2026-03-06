module uim.sap.auditlog.exceptions.configuration;

class AuditLogConfigurationException : AuditLogException {
    this(string message) {
        super("Configuration error: " ~ message);
    }
}
