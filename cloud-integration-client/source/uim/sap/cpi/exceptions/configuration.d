module uim.sap.cpi.exceptions.configuration;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

class CPIConfigurationException : CPIException {
  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
  pure nothrow @safe @nogc {
    super(msg, file, line, next);
  }
}