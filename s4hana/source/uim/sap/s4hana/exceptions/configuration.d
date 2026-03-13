module uim.sap.s4hana.exceptions.configuration;
import uim.sap.s4hana;

mixin(ShowModule!());

@safe:
class S4HANAConfigurationException : S4HANAException {
  this(string msg, string file = __FILE__, size_t line = __LINE__, Throwable next = null)
  pure nothrow @safe @nogc {
    super(msg, file, line, next);
  }
}
