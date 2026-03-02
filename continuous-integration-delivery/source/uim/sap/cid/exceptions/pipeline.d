module uim.sap.cid.exceptions.pipeline;

/// Thrown when a pipeline operation is invalid (e.g. trigger while already running)
class CIDPipelineException : CIDException {
    this(string msg) { super(msg); }
}
