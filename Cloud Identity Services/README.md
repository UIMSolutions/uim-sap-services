# SAP Cloud Identity Services Library for D

A comprehensive D language library for SAP Cloud Identity Services (IAS/IPS), built on top of uim-framework and vibe.d. This library provides SCIM 2.0 compliant APIs for managing users, groups, and roles in SAP's cloud identity platform.

## Features

- **Full SCIM 2.0 Support**: Complete implementation of System for Cross-domain Identity Management
- **User Management**: Create, read, update, delete (CRUD) operations for users
- **Group Management**: Manage groups and group memberships
- **Role Management**: Role assignments and authorization
- **OAuth2 Authentication**: Client credentials flow with automatic token refresh
- **Search & Filtering**: Advanced SCIM filtering and pagination
- **Error Handling**: Comprehensive exception hierarchy
- **Type-Safe**: Leverages D's type system for safer API operations

## Supported Services

- **Identity Authentication Service (IAS)**: User authentication and SSO
- **Identity Provisioning Service (IPS)**: User provisioning and sync
- **Identity Directory Service (IDS)**: Centralized identity management

## Installation

Add this to your `dub.sdl`:

```sdl
dependency "uim-sap:identity" version="~>1.0.0"
```

Or to your `dub.json`:

```json
{
    "dependencies": {
        "uim-sap:identity": "~>1.0.0"
    }
}
```

## Quick Start

### Basic Connection

```d
import uim.sap.ids;

void main() {
    // Create an IAS client
    auto client = IdentityClient.createIAS(
        "myaccount.accounts.ondemand.com",
        "your-client-id",
        "your-client-secret"
    );
    
    // Test connection
    if (client.testConnection()) {
        writeln("Connected successfully!");
    }
}
```

### User Management

```d
import uim.sap.ids;

void main() {
    auto client = IdentityClient.createIAS("tenant.host.com", "clientId", "secret");
    
    // Create a user
    auto user = client.users.create(
        "john.doe",              // username
        "SecurePassword123!",    // password
        "John",                  // firstName
        "Doe",                   // lastName
        "john.doe@example.com"   // email
    );
    
    writefln("User created with ID: %s", user.id);
    
    // Get user
    auto retrievedUser = client.users.get(user.id);
    
    // Update user
    retrievedUser.title = "Senior Developer";
    client.users.update(user.id, retrievedUser);
    
    // Search users
    auto activeUsers = client.users.getActive();
    auto searchResults = client.users.searchByEmail("john.doe@example.com");
    
    // Deactivate user
    client.users.deactivate(user.id);
    
    // Delete user
    client.users.remove(user.id);
}
```

### Group Management

```d
import uim.sap.ids;

void main() {
    auto client = IdentityClient.createIAS("tenant.host.com", "clientId", "secret");
    
    // Create users
    auto user1 = client.users.create("alice", "Pass123!", "Alice", "Smith", "alice@example.com");
    auto user2 = client.users.create("bob", "Pass123!", "Bob", "Jones", "bob@example.com");
    
    // Create a group with members
    auto group = client.groups.create("Developers", [user1.id, user2.id]);
    
    // Add member to group
    client.groups.addMember(group.id, "another-user-id");
    
    // Check membership
    if (client.groups.isMember(group.id, user1.id)) {
        writeln("User is a member");
    }
    
    // List groups
    auto groups = client.groups.list();
    
    // Remove member
    client.groups.removeMember(group.id, user2.id);
    
    // Delete group
    client.groups.remove(group.id);
}
```

### Advanced Search and Filtering

```d
import uim.sap.ids;

void main() {
    auto client = IdentityClient.createIAS("tenant.host.com", "clientId", "secret");
    
    // SCIM filter syntax
    auto results1 = client.users.search("userName co \"john\"");
    auto results2 = client.users.search("emails.value eq \"john@example.com\"");
    auto results3 = client.users.search("active eq true and userType eq \"Employee\"");
    
    // With pagination
    PaginationParams pagination;
    pagination.startIndex = 1;
    pagination.count = 50;
    pagination.sortBy = "userName";
    pagination.sortOrder = "ascending";
    
    auto pagedResults = client.users.list(pagination);
    
    // Helper methods
    auto byUsername = client.users.searchByUserName("john.doe");
    auto byEmail = client.users.searchByEmail("john@example.com");
    auto activeOnly = client.users.getActive();
    auto inactiveOnly = client.users.getInactive();
}
```

## Configuration

### Custom Configuration

```d
import uim.sap.ids;
import core.time : seconds;

void main() {
    IdentityConfig config;
    config.serviceType = IdentityServiceType.IAS;
    config.tenantHost = "myaccount.accounts.ondemand.com";
    config.clientId = "your-client-id";
    config.clientSecret = "your-client-secret";
    config.port = 443;
    config.useSSL = true;
    config.verifySSL = true;
    config.timeout = 60.seconds;
    config.maxRetries = 3;
    config.apiBasePath = "/service/scim/v2";
    config.customHeaders["X-Custom-Header"] = "value";
    
    auto client = new IdentityClient(config);
}
```

## SCIM 2.0 Compliance

This library implements the SCIM 2.0 standard for identity management:

### User Schema

```d
User user;
user.userName = "john.doe";           // Required
user.name.givenName = "John";
user.name.familyName = "Doe";
user.displayName = "John Doe";
user.title = "Developer";
user.active = true;
user.userType = "Employee";
user.preferredLanguage = "en-US";
user.locale = "en-US";
user.timezone = "America/Los_Angeles";

// Emails
Email email;
email.value = "john.doe@example.com";
email.type = "work";
email.primary = true;
user.emails ~= email;

// Phone numbers
PhoneNumber phone;
phone.value = "+1-555-1234";
phone.type = "work";
user.phoneNumbers ~= phone;
```

### Group Schema

```d
Group group;
group.displayName = "Developers";     // Required

// Add members
GroupMember member;
member.value = "user-id";
member.display = "John Doe";
member.type = "User";
group.members ~= member;
```

### Filtering

SCIM 2.0 filter operators:

- `eq` - Equal
- `ne` - Not equal  
- `co` - Contains
- `sw` - Starts with
- `ew` - Ends with
- `pr` - Present (has value)
- `gt` - Greater than
- `ge` - Greater than or equal
- `lt` - Less than
- `le` - Less than or equal

Examples:

```d
// Simple filters
"userName eq \"john.doe\""
"active eq true"
"emails.value co \"@example.com\""
"name.givenName sw \"John\""

// Complex filters with logical operators
"active eq true and userType eq \"Employee\""
"userName co \"doe\" or emails.value co \"doe\""
"(userName eq \"john\" or userName eq \"jane\") and active eq true"
```

## Error Handling

The library provides a comprehensive exception hierarchy:

```d
import uim.sap.ids;

try {
    auto client = IdentityClient.createIAS("host", "id", "secret");
    auto user = client.users.get("user-id");
} catch (IdentityNotFoundException e) {
    // Resource not found (404)
    writefln("Not found: %s (type: %s, id: %s)", 
        e.msg, e.resourceType, e.resourceId);
} catch (IdentityAuthenticationException e) {
    // Authentication failed (401)
    writeln("Auth error: ", e.msg);
} catch (IdentityAuthorizationException e) {
    // Authorization failed (403)
    writeln("Authorization error: ", e.msg);
} catch (IdentityValidationException e) {
    // Validation failed (400)
    writeln("Validation errors: ", e.validationErrors);
} catch (IdentityRateLimitException e) {
    // Rate limit exceeded (429)
    writefln("Rate limited. Retry after %d seconds", e.retryAfter);
} catch (IdentityException e) {
    // General identity service error
    writeln("Identity error: ", e.msg);
}
```

## API Reference

### User Operations

- `User create(User user)` - Create a new user
- `User get(string userId)` - Get user by ID
- `User update(string userId, User user)` - Update user
- `User patch(string userId, Json patchOps)` - Partial update
- `void remove(string userId)` - Delete user
- `UserListResponse list(PaginationParams)` - List users
- `UserListResponse search(string filter)` - Search users
- `UserListResponse searchByUserName(string)` - Search by username
- `UserListResponse searchByEmail(string)` - Search by email
- `UserListResponse getActive()` - Get active users
- `UserListResponse getInactive()` - Get inactive users
- `User activate(string userId)` - Activate a user
- `User deactivate(string userId)` - Deactivate a user
- `void changePassword(string userId, string newPassword)` - Change password
- `void addToGroup(string userId, string groupId)` - Add user to group
- `void removeFromGroup(string userId, string groupId)` - Remove from group

### Group Operations

- `Group create(Group group)` - Create a new group
- `Group get(string groupId)` - Get group by ID
- `Group update(string groupId, Group group)` - Update group
- `Group patch(string groupId, Json patchOps)` - Partial update
- `void remove(string groupId)` - Delete group
- `GroupListResponse list(PaginationParams)` - List groups
- `GroupListResponse search(string filter)` - Search groups
- `GroupListResponse searchByName(string)` - Search by name
- `Group addMembers(string groupId, string[] userIds)` - Add members
- `Group addMember(string groupId, string userId)` - Add single member
- `Group removeMembers(string groupId, string[] userIds)` - Remove members
- `Group removeMember(string groupId, string userId)` - Remove single member
- `string[] getMembers(string groupId)` - Get all member IDs
- `bool isMember(string groupId, string userId)` - Check membership

## Requirements

- DMD 2.100+ or LDC 1.30+
- uim-framework ~>26.1.2
- vibe.d ~>0.10.0

## License

Apache-2.0

Copyright © 2018-2026, Ozan Nurettin Süel

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

For issues and questions:
- GitHub Issues: https://github.com/UIMSolutions/uim-sap/issues
- Website: https://www.sueel.de/uim/framework

## Related Documentation

- [SAP Cloud Identity Services](https://help.sap.com/docs/SAP_CLOUD_IDENTITY)
- [SCIM 2.0 Protocol](https://datatracker.ietf.org/doc/html/rfc7644)
- [SCIM 2.0 Core Schema](https://datatracker.ietf.org/doc/html/rfc7643)
