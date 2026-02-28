module uim.sap.cre.helpers.helper;

import uim.sap.cre;

mixin(ShowModule!());

@safe:

string generateSecretToken() {
  return randomUUID().toString().replace("-", "");
}
