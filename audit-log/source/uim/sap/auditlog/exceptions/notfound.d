module uim.sap.auditlog.exceptions.notfound;

class AuditLogNotFoundException : AuditLogException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}
