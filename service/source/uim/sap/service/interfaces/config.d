module uim.sap.service.interfaces.config;
import uim.sap.service;

mixin(ShowModule!());

@safe:
interface ISAPConfig {
  string serviceName();
  string serviceVersion();
}