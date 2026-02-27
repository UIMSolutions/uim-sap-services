/**
 * Fiori client basic usage examples
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module examples.basic_usage;

import std.stdio : writeln;
import vibe.d;
import uim.sap.fiori;

void main() {
    // Example 1: Basic configuration and connection
    writeln("Example 1: Basic Configuration");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        config.sapClient = "100";
        
        auto client = new FioriClient(config);
        
        if (client.testConnection()) {
            writeln("✓ Connected to Fiori system");
        }
    }
    
    // Example 2: OData query with filters
    writeln("\nExample 2: OData Query");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        // Build query with options
        ODataQueryOptions options;
        options.select = ["ProductID", "ProductName", "Price"];
        options.filter = "Price gt 100";
        options.orderBy = "ProductName asc";
        options.top = 10;
        
        try {
            auto result = client.odata.readEntitySet("Products", options);
            writeln("Products: ", result.toString());
        } catch (ODataException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 3: Create entity
    writeln("\nExample 3: Create Entity");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        Json newProduct = Json.emptyObject;
        newProduct["ProductID"] = "12345";
        newProduct["ProductName"] = "New Product";
        newProduct["Price"] = 99.99;
        newProduct["Category"] = "Electronics";
        
        try {
            auto result = client.odata.createEntity("Products", newProduct);
            writeln("Created product: ", result.toString());
        } catch (ODataException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 4: Update entity
    writeln("\nExample 4: Update Entity");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        Json updates = Json.emptyObject;
        updates["Price"] = 89.99;
        updates["InStock"] = true;
        
        try {
            auto result = client.odata.updateEntity("Products", "12345", updates);
            writeln("Updated product: ", result.toString());
        } catch (ODataException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 5: Launchpad groups
    writeln("\nExample 5: Launchpad Groups");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        try {
            auto groups = client.launchpad.getGroups();
            writeln("User groups:");
            foreach (group; groups) {
                writeln("  - ", group.title);
            }
        } catch (LaunchpadException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 6: Create tile group
    writeln("\nExample 6: Create Tile Group");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        try {
            auto newGroup = client.launchpad.createGroup("My Custom Group");
            writeln("Created group: ", newGroup.title);
            
            // Add tile to group
            LaunchpadTile tile;
            tile.title = "Sales Dashboard";
            tile.subtitle = "View sales data";
            tile.icon = "sap-icon://bar-chart";
            tile.semanticObject = "SalesOrder";
            tile.action = "display";
            
            client.launchpad.addTileToGroup(newGroup.id, tile);
            writeln("Added tile to group");
        } catch (LaunchpadException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 7: Navigation
    writeln("\nExample 7: Navigation");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        // Create navigation intent
        string[string] params;
        params["SalesOrderID"] = "12345";
        
        auto intent = client.navigation.createIntent("SalesOrder", "display", params);
        writeln("Navigation hash: ", intent.toHash());
        writeln("Navigation URL: ", client.navigation.getNavigationUrl(intent));
        
        // Parse hash
        auto parsed = NavigationService.parseHash("#SalesOrder-display?SalesOrderID=12345");
        writeln("Parsed semantic object: ", parsed.semanticObject);
        writeln("Parsed action: ", parsed.action);
    }
    
    // Example 8: Personalization
    writeln("\nExample 8: Personalization");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        try {
            // Get current settings
            auto settings = client.personalization.getSettings();
            writeln("Current theme: ", settings.theme);
            writeln("Current language: ", settings.language);
            
            // Save variant
            Variant variant;
            variant.name = "My Filter Variant";
            variant.key = "VAR001";
            variant.data = Json.emptyObject;
            variant.data["filters"] = Json(["status": Json("active")]);
            variant.isDefault = true;
            
            client.personalization.saveVariant("MyApp.FilterBar", variant);
            writeln("Saved variant");
        } catch (FioriException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 9: OData with $expand
    writeln("\nExample 9: OData Expand");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        ODataQueryOptions options;
        options.select = ["SalesOrderID", "CustomerName", "TotalAmount"];
        options.expand = ["Items", "Customer"];
        options.filter = "TotalAmount gt 1000";
        
        try {
            auto result = client.odata.readEntitySet("SalesOrders", options);
            writeln("Sales orders with expanded items: ", result.toString());
        } catch (ODataException e) {
            writeln("Error: ", e.msg);
        }
    }
    
    // Example 10: Function import
    writeln("\nExample 10: Function Import");
    {
        auto config = FioriConfig.createBasic(
            "https://myfiori.sapserver.com",
            "myuser",
            "mypassword"
        );
        
        auto client = new FioriClient(config);
        
        Json params = Json.emptyObject;
        params["Year"] = 2024;
        params["Month"] = 3;
        
        try {
            auto result = client.odata.callFunction("CalculateTotalSales", params);
            writeln("Function result: ", result.toString());
        } catch (ODataException e) {
            writeln("Error: ", e.msg);
        }
    }
}
