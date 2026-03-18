module uim.sap.slm.exceptions.solution;

/// Thrown when a solution state transition is illegal
class SLMSolutionStateException : SLMException {
    this(string msg) { super(msg); }
}
