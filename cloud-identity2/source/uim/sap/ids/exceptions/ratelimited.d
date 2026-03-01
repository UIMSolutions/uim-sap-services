module uim.sap.ids.exceptions.ratelimited;

import uim.sap.ids;
@safe:

/**
 * Exception thrown when rate limit is exceeded
 */
class IdentityRateLimitException : IdentityException {
    long retryAfter; // seconds
    
    this(string msg, long retry = 0, string file = __FILE__, size_t line = __LINE__, Throwable nextInChain = null) pure nothrow @safe {
        super(msg, file, line, nextInChain);
        this.retryAfter = retry;
    }
}