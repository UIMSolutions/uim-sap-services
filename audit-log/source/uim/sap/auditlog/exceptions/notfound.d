module uim.sap.auditlog.exceptions.notfound;
import uim.sap.auditlog;

mixin(ShowModule!());

@safe:
class AuditLogNotFoundException : AuditLogException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}
