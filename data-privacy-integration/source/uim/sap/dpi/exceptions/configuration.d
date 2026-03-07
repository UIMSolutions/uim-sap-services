module uim.sap.dpi.exceptions.configuration;
import uim.sap.dpi;

mixin(ShowModule!());

@safe:
class DPIConfigurationException : DPIException {
    this(string msg) { super(msg); }
}
