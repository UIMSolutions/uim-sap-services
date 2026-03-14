module uim.sap.mob.exceptions.quota;

import uim.sap.mob;

mixin(ShowModule!());

@safe:

class MOBQuotaExceededException : MOBException {
  this(string resource, size_t limit, string file = __FILE__, size_t line = __LINE__) {
    import std.conv : to;

    super("Quota exceeded for " ~ resource ~ ": maximum " ~ limit.to!string, file, line);
  }
}
