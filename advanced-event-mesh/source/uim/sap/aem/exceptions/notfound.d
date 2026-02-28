module uim.sap.aem.exceptions.notfound;




class AEMNotFoundException : AEMException {
    this(string resource, string identifier) {
        super(resource ~ " not found: " ~ identifier);
    }
}


