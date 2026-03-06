module uim.sap.auditlog.exceptions.validation;

class AuditLogValidationException : AuditLogException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}