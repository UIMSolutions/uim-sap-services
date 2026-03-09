module uim.sap.mdg.exceptions.notfound;

import uim.sap.mdg;

mixin(ShowModule!());

@safe:

/** 
 * Exception thrown when a requested entity is not found.
 */
class MDGNotFoundException : MDGException {
  this(string kind, string id) {
    super(kind ~ " not found: " ~ id);
  }
}
