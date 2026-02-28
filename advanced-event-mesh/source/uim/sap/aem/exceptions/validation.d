module uim.sap.aem.exceptions.validation;

class AEMValidationException : AEMException {
    this(string message) {
        super("Validation failed: " ~ message);
    }
}