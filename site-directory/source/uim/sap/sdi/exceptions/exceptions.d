/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.sdi.exceptions.exceptions;

class SDIException : SAPException {
    this(string msg) { super(msg); }
}

class SDIValidationException : SDIException {
    this(string msg) { super(msg); }
}

class SDINotFoundException : SDIException {
    this(string msg) { super(msg); }
}

class SDIAuthorizationException : SDIException {
    this(string msg) { super(msg); }
}

class SDIConfigurationException : SDIException {
    this(string msg) { super(msg); }
}
