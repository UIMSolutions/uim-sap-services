module middlewares.security_headers;

import vibe.vibe;


/**
  * This middleware adds security headers to the response.
  *
  * To use this middleware, add it to your server configuration before your route handlers.
  * Example:
  *     auto server = new HTTPServer();
  *     server.addMiddleware(new SecurityHeadersMiddleware());
  */
class SecurityHeadersMiddleware
{
    // This middleware adds security headers to the response
    void handleRequest(HTTPServerRequest req, HTTPServerResponse res)
    {
        // Set security headers
        res.headers["Strict-Transport-Security"] = "max-age=63072000; includeSubDomains";
        res.headers["Content-Security-Policy"] = "default-src 'self'";
        res.headers["X-Content-Type-Options"] = "nosniff";
        res.headers["X-Frame-Options"] = "DENY";
        res.headers["X-XSS-Protection"] = "1; mode=block";

        // Call the next middleware or route handler
        next(req, res);
    }
}