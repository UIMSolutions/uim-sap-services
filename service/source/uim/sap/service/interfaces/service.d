module uim.sap.service.interfaces.service;
import uim.sap.service;

mixin(ShowModule!());

@safe:
interface ISAPService {
  ISAPConfig config() const;
  void config(ISAPConfig cfg);

  Json health();
  Json ready();
}
