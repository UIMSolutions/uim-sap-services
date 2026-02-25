module uim.sap.jobs.exceptions.notfound;







class JobSchedulingNotFoundException : JobSchedulingException {
    this(string kind, string id) { super(kind ~ " not found: " ~ id); }
}
