module uim.sap.featureflags.exceptions.exception;

import uim.sap.featureflags;

mixin(ShowModule!());

@safe:

class FFException : Exception {
  this(string message) {
    super(message);
  }
}
