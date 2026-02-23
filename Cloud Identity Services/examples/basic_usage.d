/**
 * Example usage of SAP Cloud Identity Services Library
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
import uim.sap.ids;
import std.stdio : writeln, writefln;

void main() {
    writeln("=== SAP Cloud Identity Services Library Examples ===\n");
    
    // Example 1: Basic Connection
    basicConnectionExample();
    
    // Example 2: User Management
    userManagementExample();
    
    // Example 3: Group Management
    groupManagementExample();
    
    // Example 4: Search and Filter
    searchExample();
    
    // Example 5: Role Management
    roleManagementExample();
}

void basicConnectionExample() {
    writeln("--- Example 1: Basic Connection ---");
    
    try {
        // Create IAS client
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "your-client-id",
            "your-client-secret"
        );
        
        // Test connection
        if (client.testConnection()) {
            writeln("✓ Successfully connected to SAP Cloud Identity Services");
        } else {
            writeln("✗ Connection failed");
        }
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void userManagementExample() {
    writeln("--- Example 2: User Management ---");
    
    try {
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "client-id",
            "client-secret"
        );
        
        // Create a new user
        writeln("Creating new user...");
        auto newUser = client.users.create(
            "john.doe",           // userName
            "SecurePassword123!", // password
            "John",               // givenName
            "Doe",                // familyName
            "john.doe@example.com" // email
        );
        writefln("✓ User created with ID: %s", newUser.id);
        
        // Get user by ID
        writeln("\nRetrieving user...");
        auto user = client.users.get(newUser.id);
        writefln("✓ Retrieved user: %s (%s)", user.userName, user.displayName);
        
        // Update user
        writeln("\nUpdating user...");
        user.title = "Senior Developer";
        user.displayName = "John Doe";
        auto updatedUser = client.users.update(user.id, user);
        writefln("✓ User updated: %s", updatedUser.title);
        
        // List all users
        writeln("\nListing users...");
        PaginationParams pagination;
        pagination.count = 10;
        auto userList = client.users.list(pagination);
        writefln("✓ Found %d users (total: %d)", userList.resources.length, userList.totalResults);
        
        foreach (u; userList.resources) {
            writefln("  - %s (%s)", u.userName, u.displayName);
        }
        
        // Deactivate user
        writeln("\nDeactivating user...");
        client.users.deactivate(newUser.id);
        writeln("✓ User deactivated");
        
        // Reactivate user
        writeln("Reactivating user...");
        client.users.activate(newUser.id);
        writeln("✓ User activated");
        
        // Change password
        writeln("\nChanging password...");
        client.users.changePassword(newUser.id, "NewSecurePassword456!");
        writeln("✓ Password changed");
        
        // Delete user
        writeln("\nDeleting user...");
        client.users.remove(newUser.id);
        writeln("✓ User deleted");
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void groupManagementExample() {
    writeln("--- Example 3: Group Management ---");
    
    try {
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "client-id",
            "client-secret"
        );
        
        // Create users first
        auto user1 = client.users.create("alice", "Pass123!", "Alice", "Smith", "alice@example.com");
        auto user2 = client.users.create("bob", "Pass123!", "Bob", "Jones", "bob@example.com");
        
        // Create a group
        writeln("Creating new group...");
        auto newGroup = client.groups.create("Developers", [user1.id, user2.id]);
        writefln("✓ Group created with ID: %s", newGroup.id);
        
        // Get group
        writeln("\nRetrieving group...");
        auto group = client.groups.get(newGroup.id);
        writefln("✓ Retrieved group: %s (%d members)", group.displayName, group.members.length);
        
        // List group members
        writeln("Group members:");
        foreach (member; group.members) {
            writefln("  - %s (%s)", member.value, member.display);
        }
        
        // Create another user
        auto user3 = client.users.create("charlie", "Pass123!", "Charlie", "Brown", "charlie@example.com");
        
        // Add member to group
        writeln("\nAdding member to group...");
        client.groups.addMember(newGroup.id, user3.id);
        writeln("✓ Member added");
        
        // Check membership
        if (client.groups.isMember(newGroup.id, user3.id)) {
            writeln("✓ User is a member of the group");
        }
        
        // Remove member from group
        writeln("\nRemoving member from group...");
        client.groups.removeMember(newGroup.id, user3.id);
        writeln("✓ Member removed");
        
        // List all groups
        writeln("\nListing groups...");
        auto groupList = client.groups.list();
        writefln("✓ Found %d groups", groupList.totalResults);
        
        // Clean up
        client.groups.remove(newGroup.id);
        client.users.remove(user1.id);
        client.users.remove(user2.id);
        client.users.remove(user3.id);
        writeln("✓ Cleanup completed");
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void searchExample() {
    writeln("--- Example 4: Search and Filter ---");
    
    try {
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "client-id",
            "client-secret"
        );
        
        // Search users by username
        writeln("Searching for users with username containing 'john'...");
        auto results1 = client.users.search("userName co \"john\"");
        writefln("✓ Found %d users", results1.totalResults);
        
        // Search users by email
        writeln("\nSearching for users by email...");
        auto results2 = client.users.searchByEmail("john.doe@example.com");
        writefln("✓ Found %d users", results2.totalResults);
        
        // Get active users only
        writeln("\nGetting active users...");
        auto activeUsers = client.users.getActive();
        writefln("✓ Found %d active users", activeUsers.totalResults);
        
        // Get inactive users
        writeln("Getting inactive users...");
        auto inactiveUsers = client.users.getInactive();
        writefln("✓ Found %d inactive users", inactiveUsers.totalResults);
        
        // Search groups by name
        writeln("\nSearching for groups...");
        auto groups = client.groups.searchByName("Developers");
        writefln("✓ Found %d groups", groups.totalResults);
        
        // Custom filter with pagination
        writeln("\nUsing custom filter with pagination...");
        PaginationParams pagination;
        pagination.startIndex = 1;
        pagination.count = 5;
        pagination.sortBy = "userName";
        pagination.sortOrder = "ascending";
        
        auto results = client.users.search("active eq true", pagination);
        writefln("✓ Found %d users (showing %d-%d of %d)",
            results.resources.length,
            results.startIndex,
            results.startIndex + results.itemsPerPage - 1,
            results.totalResults);
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void roleManagementExample() {
    writeln("--- Example 5: Role Management ---");
    
    try {
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "client-id",
            "client-secret"
        );
        
        // Note: Role management API depends on specific tenant configuration
        // This is a simplified example
        
        writeln("This example requires specific role configuration in your tenant.");
        writeln("Role management APIs may vary based on your IAS/IPS setup.");
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}

void errorHandlingExample() {
    writeln("--- Example 6: Error Handling ---");
    
    try {
        auto client = IdentityClient.createIAS(
            "myaccount.accounts.ondemand.com",
            "client-id",
            "client-secret"
        );
        
        // Try to get a non-existent user
        try {
            client.users.get("non-existent-id");
        } catch (IdentityNotFoundException e) {
            writefln("✓ Caught NotFoundException: %s", e.msg);
            writefln("  Resource Type: %s", e.resourceType);
            writefln("  Resource ID: %s", e.resourceId);
        }
        
        // Handle authentication errors
        try {
            auto badClient = IdentityClient.createIAS(
                "invalid.host.com",
                "bad-id",
                "bad-secret"
            );
            badClient.testConnection();
        } catch (IdentityAuthenticationException e) {
            writefln("✓ Caught AuthenticationException: %s", e.msg);
        }
        
        // Handle validation errors
        try {
            IdentityConfig config;
            config.validate(); // Missing required fields
        } catch (IdentityConfigurationException e) {
            writefln("✓ Caught ConfigurationException: %s", e.msg);
        }
        
        writeln();
    } catch (IdentityException e) {
        writeln("✗ Error: ", e.msg);
    }
}
