module uim.sap.auditlog.exceptions.authorization;

class AuditLogAuthorizationException : AuditLogException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}