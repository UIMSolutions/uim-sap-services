module middlewares.tls;

import vibe.vibe;

/**
  * This middleware ensures that all incoming requests are served over HTTPS
  * and manages TLS-related configurations.
  *
  * To use this middleware, add it to your server configuration before your route handlers.
  * Example:
  *     auto server = new HTTPServer();
  *     server.addMiddleware(new TlsMiddleware());
  */
class TlsMiddleware {
    // This middleware ensures that all incoming requests are served over HTTPS
    // and manages TLS-related configurations.

    void handleRequest(HTTPServerRequest req, HTTPServerResponse res) {
        // Check if the request is secure
        if (!req.isSecure()) {
            // Redirect to HTTPS
            res.redirect("https://" ~ req.host ~ req.url);
            return;
        }

        // Additional TLS-related configurations can be added here
        // For example, setting specific headers or logging

        // Proceed to the next middleware or request handler
        next(req, res);
    }
}