module uim.sap.cdc.exceptions.store;
import uim.sap.cdc;

mixin(ShowModule!());

@safe:
class CDCStoreException : CDCException {
  this(string message, string file = __FILE__, size_t line = __LINE__) {
    super(message, file, line);
  }
}