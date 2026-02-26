module uim.sap.mgt.exceptions.authorization;

import uim.sap.mgt;

mixin(ShowModule!());

@safe:
/**
    * This file defines the MGTAuthorizationException class, which is used to represent exceptions related to authorization issues in the SAP Management module.
    * It extends the MGTException class, allowing it to be used in a consistent way with other exceptions in the module.
    * The constructor takes a string message as an argument, which can be used to provide more details about the specific authorization issue that occurred.
    */
class MGTAuthorizationException : MGTException {
    this(string msg) {
        super(msg);
    }
}