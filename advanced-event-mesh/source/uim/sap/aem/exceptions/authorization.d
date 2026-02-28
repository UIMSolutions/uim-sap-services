module uim.sap.aem.exceptions.authorization;

class AEMAuthorizationException : AEMException {
    this(string message) {
        super("Unauthorized: " ~ message);
    }
}