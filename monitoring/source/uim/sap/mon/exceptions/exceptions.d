/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.mon.exceptions.exceptions;

class MONException : SAPException {
    this(string msg) {
        super(msg);
    }
}

class MONConfigurationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONAuthorizationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONValidationException : MONException {
    this(string msg) {
        super(msg);
    }
}

class MONNotFoundException : MONException {
    this(string kind, string id) {
        super(kind ~ " not found: " ~ id);
    }
}
