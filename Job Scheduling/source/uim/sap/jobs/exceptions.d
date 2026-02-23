module uim.sap.jobs.exceptions;

class JobSchedulingException : Exception {
    this(string msg) { super(msg); }
}

class JobSchedulingConfigurationException : JobSchedulingException {
    this(string msg) { super(msg); }
}

class JobSchedulingAuthorizationException : JobSchedulingException {
    this(string msg) { super(msg); }
}

class JobSchedulingValidationException : JobSchedulingException {
    this(string msg) { super(msg); }
}

class JobSchedulingNotFoundException : JobSchedulingException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
