module app;

import vibe.vibe;
import source.routes.api_routes;

void main() {
    // Initialize the Vibe.D web server
    auto settings = new HTTPServerSettings;
    settings.port = 8080; // Set the server port
    settings.bindAddresses = ["0.0.0.0"]; // Bind to all addresses

    // Set up routing
    auto router = new Router;
    api_routes.setupRoutes(router);

    // Start the application
    runApplication(settings);
}