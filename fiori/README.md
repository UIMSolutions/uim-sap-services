# Fiori Client Library for D

A comprehensive D language library for working with Fiori applications, OData services, and Fiori Launchpad using the uim-framework and vibe.d.

## Features

### OData Client
- **CRUD Operations**: Full create, read, update, delete support for OData entities
- **Query Builder**: Fluent API for $select, $filter, $expand, $orderby, $top, $skip
- **Batch Requests**: Execute multiple operations in a single request
- **Function Imports**: Call custom functions
- **Metadata Service**: Parse and query OData service metadata
- **CSRF Token Handling**: Automatic token management for write operations
- **OData v2/v3/v4**: Support for multiple OData protocol versions

### Fiori Launchpad
- **Tile Management**: Create, read, update, delete tiles
- **Group Management**: Organize tiles into groups
- **Catalog Access**: Browse available applications in catalogs
- **Personalization**: User-specific launchpad configuration

### Navigation
- **Intent-based Navigation**: Semantic object and action-based routing
- **Cross-app Navigation**: Navigate between Fiori applications
- **Shell Services**: Interact with Fiori shell (title, messages, back navigation)
- **Hash Parsing**: Convert URLs to navigation intents

### Personalization
- **User Settings**: Theme, language, date/time formats
- **Variants**: Save and load filter/view configurations
- **Custom Settings**: Application-specific personalization

## Installation

Add to your `dub.json`:
```json
{
    "dependencies": {
        "uim-fiori": "~>1.0.0"
    }
}
```

Or to your `dub.sdl`:
```sdl
dependency "uim-fiori" version="~>1.0.0"
```

## Quick Start

### Basic Configuration

```d
import uim.sap.fiori;

// Create configuration
auto config = FioriConfig.createBasic(
    "https://myfiori.sapserver.com",
    "myuser",
    "mypassword"
);
config.sapClient = "100";

// Create client
auto client = new FioriClient(config);

// Test connection
if (client.testConnection()) {
    writeln("Connected!");
}
```

### OData Queries

```d
// Simple read
auto result = client.odata.readEntitySet("Products");

// With query options
ODataQueryOptions options;
options.select = ["ProductID", "ProductName", "Price"];
options.filter = "Price gt 100";
options.orderBy = "ProductName asc";
options.top = 10;

auto products = client.odata.readEntitySet("Products", options);
```

### Create Entity

```d
Json newProduct = Json.emptyObject;
newProduct["ProductID"] = "12345";
newProduct["ProductName"] = "New Product";
newProduct["Price"] = 99.99;

auto result = client.odata.createEntity("Products", newProduct);
```

### Update Entity

```d
Json updates = Json.emptyObject;
updates["Price"] = 89.99;

client.odata.updateEntity("Products", "12345", updates);
```

### Launchpad Operations

```d
// Get user's tile groups
auto groups = client.launchpad.getGroups();

// Create new group
auto newGroup = client.launchpad.createGroup("My Group");

// Add tile to group
LaunchpadTile tile;
tile.title = "Sales Dashboard";
tile.subtitle = "View sales data";
tile.icon = "sap-icon://bar-chart";
tile.semanticObject = "SalesOrder";
tile.action = "display";

client.launchpad.addTileToGroup(newGroup.id, tile);
```

### Navigation

```d
// Create navigation intent
string[string] params;
params["SalesOrderID"] = "12345";

auto intent = client.navigation.createIntent("SalesOrder", "display", params);

// Get navigation URL
auto url = client.navigation.getNavigationUrl(intent);
// Result: https://myfiori.sapserver.com#SalesOrder-display?SalesOrderID=12345

// Parse hash
auto parsed = NavigationService.parseHash("#SalesOrder-display?SalesOrderID=12345");
writeln(parsed.semanticObject); // "SalesOrder"
writeln(parsed.action);          // "display"
```

### Personalization

```d
// Get user settings
auto settings = client.personalization.getSettings();
writeln(settings.theme);
writeln(settings.language);

// Save variant
Variant variant;
variant.name = "My Filter Variant";
variant.key = "VAR001";
variant.data = Json.emptyObject;
variant.data["filters"] = Json(["status": Json("active")]);

client.personalization.saveVariant("MyApp.FilterBar", variant);
```

## Advanced Features

### OData $expand

```d
ODataQueryOptions options;
options.select = ["SalesOrderID", "CustomerName"];
options.expand = ["Items", "Customer"];  // Expand navigation properties

auto orders = client.odata.readEntitySet("SalesOrders", options);
```

### Function Imports

```d
Json params = Json.emptyObject;
params["Year"] = 2024;
params["Month"] = 3;

auto result = client.odata.callFunction("CalculateTotalSales", params);
```

### Batch Operations

```d
ODataBatchRequest[] requests;

// Add multiple requests
ODataBatchRequest req1;
req1.method = "GET";
req1.url = "/Products('12345')";
requests ~= req1;

ODataBatchRequest req2;
req2.method = "POST";
req2.url = "/Products";
req2.body = newProductJson;
requests ~= req2;

auto responses = client.odata.executeBatch(requests);
```

### Metadata Exploration

```d
auto metadata = client.odata.fetchMetadata();
// Returns XML metadata document with entity definitions
```

## Authentication

### Basic Authentication

```d
auto config = FioriConfig.createBasic(
    "https://myfiori.sapserver.com",
    "username",
    "password"
);
```

### OAuth2

```d
auto config = FioriConfig.createOAuth(
    "https://myfiori.sapserver.com",
    "your_oauth_token"
);
```

### API Key

```d
FioriConfig config;
config.baseUrl = "https://myfiori.sapserver.com";
config.authType = AuthenticationType.ApiKey;
config.apiKey = "your_api_key";
```

## Configuration Options

```d
FioriConfig config;
config.baseUrl = "https://myfiori.sapserver.com";
config.port = 443;
config.useSSL = true;
config.sapClient = "100";                    // client number
config.sapLanguage = "EN";                   // Language code
config.timeout = dur!"seconds"(30);          // Request timeout
config.maxRetries = 3;                       // Connection retries
config.verifySSL = true;                     // SSL certificate verification
config.odataVersion = ODataVersion.V2;       // OData version (V2, V3, V4)
config.enableCSRF = true;                    // CSRF token handling
```

## Error Handling

```d
try {
    auto result = client.odata.readEntitySet("Products");
} catch (ODataException e) {
    writeln("OData error: ", e.msg);
    writeln("Status code: ", e.statusCode);
    writeln("Error code: ", e.odataError.code);
} catch (FioriConnectionException e) {
    writeln("Connection failed: ", e.msg);
} catch (FioriAuthenticationException e) {
    writeln("Authentication failed: ", e.msg);
}
```

## Examples

See the `examples/` directory for complete working examples:
- `basic_usage.d` - Common operations and patterns
- OData queries with filters and expansion
- Launchpad tile and group management
- Navigation intent handling
- Personalization and variants

## Gateway Compatibility

This library is designed to work with:
- Gateway Foundation (NetWeaver)
- S/4HANA (Cloud and On-Premise)
- Business Technology Platform (BTP)
- Cloud Platform
- Any OData-compliant service

## Requirements

- DMD 2.100+ or LDC 1.30+
- uim-framework ~>26.1.2
- vibe.d ~>0.10.0

## License

Apache License 2.0 - see LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Links

- [Repository](https://github.com/UIMSolutions/uim-sap)
- [OData Documentation](https://www.odata.org/)
- [Fiori Design Guidelines](https://experience.sap.com/fiori-design/)
- [Gateway Documentation](https://help.sap.com/docs/SAP_GATEWAY)

## Author

Ozan Nurettin Süel

Copyright © 2018-2026, Ozan Nurettin Süel
