module uim.sap.cia.exceptions.automation;
import uim.sap.cia;

mixin(ShowModule!());

@safe:

class CIAAutomationException : CIAException {
  this(string message) {
    super(message);
  }
}
