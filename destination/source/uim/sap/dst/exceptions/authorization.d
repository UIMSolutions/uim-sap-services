module uim.sap.dst.exceptions.authorization;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
class DSTAuthorizationException : DSTException {
  this(string msg) {
    super(msg);
  }
}
