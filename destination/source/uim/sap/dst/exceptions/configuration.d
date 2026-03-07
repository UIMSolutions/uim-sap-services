module uim.sap.dst.exceptions.configuration;
import uim.sap.dst;

mixin(ShowModule!());

@safe:
class DSTConfigurationException : DSTException {
    this(string msg) { super(msg); }
}
