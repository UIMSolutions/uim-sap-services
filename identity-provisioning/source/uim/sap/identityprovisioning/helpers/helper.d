module uim.sap.identityprovisioning.helpers.helper;

import uim.sap.identityprovisioning;

mixin(ShowModule!());

@safe:

/** Evaluate a simple filter condition against a string value.
 *
 *  Supported operators:
 *  - "equals <value>"
 *  - "contains <value>"
 *  - "startsWith <value>"
 *  - "endsWith <value>"
 *  - "notEquals <value>"
 *
 *  Returns true if the condition matches.  Empty conditions always match.
 */
bool evaluateCondition(string condition, string value) {
    if (condition.length == 0) return true;

    // Split on first space
    auto spaceIdx = indexOf(condition, ' ');
    if (spaceIdx < 0) return true;

    auto op = condition[0 .. spaceIdx];
    auto operand = condition[spaceIdx + 1 .. $];

    switch (op) {
        case "equals":     return value == operand;
        case "notEquals":  return value != operand;
        case "contains":   return indexOf(value, operand) >= 0;
        case "startsWith": return value.length >= operand.length && value[0 .. operand.length] == operand;
        case "endsWith":   return value.length >= operand.length && value[$ - operand.length .. $] == operand;
        default:           return true;
    }
}

/** Find the index of a character in a string, or -1. */
private long indexOf(string haystack, char needle) {
    foreach (i, c; haystack) {
        if (c == needle) return cast(long) i;
    }
    return -1;
}

/** Find the index of a substring in a string, or -1. */
private long indexOf(string haystack, string needle) {
    if (needle.length == 0) return 0;
    if (haystack.length < needle.length) return -1;

    foreach (i; 0 .. haystack.length - needle.length + 1) {
        if (haystack[i .. i + needle.length] == needle)
            return cast(long) i;
    }
    return -1;
}
