module uim.sap.dst.exceptions.destination;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
/// Thrown for destination-specific operational errors (connectivity, auth flow failure, etc.)
class DSTDestinationException : DSTException {
  this(string msg) {
    super(msg);
  }
}
