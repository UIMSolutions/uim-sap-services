module uim.sap.cia.exceptions.workflowstate;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

class CIAWorkflowStateException : CIAException {
  this(string message) {
    super(message);
  }
}
