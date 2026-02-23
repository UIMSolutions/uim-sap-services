/**
 * User models for SAP Cloud Identity Services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.ids.structs.user;

import vibe.data.json;
import std.datetime : SysTime;

/**
 * User status in the identity system
 */
enum UserStatus {
    Active,
    Inactive,
    Locked,
    Pending,
    Deleted
}

/**
 * Email address with type
 */
struct Email {
    string value;
    string type = "work";  // work, home, other
    bool primary = false;
}

/**
 * Phone number with type
 */
struct PhoneNumber {
    string value;
    string type = "work";  // work, home, mobile, fax, other
    bool primary = false;
}

/**
 * Physical address
 */
struct Address {
    string formatted;
    string streetAddress;
    string locality;
    string region;
    string postalCode;
    string country;
    string type = "work";  // work, home, other
    bool primary = false;
}

/**
 * User name structure
 */
struct UserName {
    string formatted;
    string givenName;
    string familyName;
    string middleName;
    string honorificPrefix;
    string honorificSuffix;
}

/**
 * Enterprise user extension attributes
 */
struct EnterpriseUser {
    string employeeNumber;
    string costCenter;
    string organization;
    string division;
    string department;
    string manager;
}

/**
 * User metadata
 */
struct UserMeta {
    SysTime created;
    SysTime lastModified;
    string location;
    string resourceType = "User";
    string version_;
}

/**
 * User representation in SAP Cloud Identity Services (SCIM 2.0 compliant)
 */
struct User {
    /// Unique identifier
    string id;
    
    /// External identifier
    string externalId;
    
    /// Username (required)
    string userName;
    
    /// User name components
    UserName name;
    
    /// Display name
    string displayName;
    
    /// Nick name
    string nickName;
    
    /// Profile URL
    string profileUrl;
    
    /// Title (e.g., "Director")
    string title;
    
    /// User type (e.g., "Employee", "Contractor")
    string userType;
    
    /// Preferred language (e.g., "en-US")
    string preferredLanguage;
    
    /// Locale (e.g., "en-US")
    string locale;
    
    /// Timezone (e.g., "America/Los_Angeles")
    string timezone;
    
    /// Active status
    bool active = true;
    
    /// Password (write-only)
    string password;
    
    /// Emails
    Email[] emails;
    
    /// Phone numbers
    PhoneNumber[] phoneNumbers;
    
    /// Addresses
    Address[] addresses;
    
    /// Groups the user belongs to
    string[] groups;
    
    /// Roles assigned to the user
    string[] roles;
    
    /// Enterprise extension
    EnterpriseUser enterprise;
    
    /// Metadata
    UserMeta meta;
    
    /// Custom attributes
    Json[string] customAttributes;
    
    /**
     * Convert user to JSON for API requests
     */
    Json toJson() const {
        Json json = Json.emptyObject;
        
        json["schemas"] = Json(["urn:ietf:params:scim:schemas:core:2.0:User"]);
        
        if (id.length > 0) {
            json["id"] = id;
        }
        
        if (externalId.length > 0) {
            json["externalId"] = externalId;
        }
        
        json["userName"] = userName;
        
        if (name.formatted.length > 0 || name.givenName.length > 0 || name.familyName.length > 0) {
            auto nameJson = Json.emptyObject;
            if (name.formatted.length > 0) nameJson["formatted"] = name.formatted;
            if (name.givenName.length > 0) nameJson["givenName"] = name.givenName;
            if (name.familyName.length > 0) nameJson["familyName"] = name.familyName;
            if (name.middleName.length > 0) nameJson["middleName"] = name.middleName;
            if (name.honorificPrefix.length > 0) nameJson["honorificPrefix"] = name.honorificPrefix;
            if (name.honorificSuffix.length > 0) nameJson["honorificSuffix"] = name.honorificSuffix;
            json["name"] = nameJson;
        }
        
        if (displayName.length > 0) {
            json["displayName"] = displayName;
        }
        
        if (title.length > 0) {
            json["title"] = title;
        }
        
        if (userType.length > 0) {
            json["userType"] = userType;
        }
        
        json["active"] = active;
        
        if (password.length > 0) {
            json["password"] = password;
        }
        
        if (emails.length > 0) {
            Json[] emailsJson;
            foreach (email; emails) {
                auto emailJson = Json.emptyObject;
                emailJson["value"] = email.value;
                emailJson["type"] = email.type;
                emailJson["primary"] = email.primary;
                emailsJson ~= emailJson;
            }
            json["emails"] = Json(emailsJson);
        }
        
        if (phoneNumbers.length > 0) {
            Json[] phonesJson;
            foreach (phone; phoneNumbers) {
                auto phoneJson = Json.emptyObject;
                phoneJson["value"] = phone.value;
                phoneJson["type"] = phone.type;
                phoneJson["primary"] = phone.primary;
                phonesJson ~= phoneJson;
            }
            json["phoneNumbers"] = Json(phonesJson);
        }
        
        return json;
    }
    
    /**
     * Create user from JSON response
     */
    static User fromJson(Json json) {
        User user;
        
        if ("id" in json) {
            user.id = json["id"].get!string;
        }
        
        if ("externalId" in json) {
            user.externalId = json["externalId"].get!string;
        }
        
        if ("userName" in json) {
            user.userName = json["userName"].get!string;
        }
        
        if ("name" in json) {
            auto nameJson = json["name"];
            if ("formatted" in nameJson) user.name.formatted = nameJson["formatted"].get!string;
            if ("givenName" in nameJson) user.name.givenName = nameJson["givenName"].get!string;
            if ("familyName" in nameJson) user.name.familyName = nameJson["familyName"].get!string;
            if ("middleName" in nameJson) user.name.middleName = nameJson["middleName"].get!string;
        }
        
        if ("displayName" in json) {
            user.displayName = json["displayName"].get!string;
        }
        
        if ("title" in json) {
            user.title = json["title"].get!string;
        }
        
        if ("active" in json) {
            user.active = json["active"].get!bool;
        }
        
        if ("emails" in json && json["emails"].type == Json.Type.array) {
            foreach (emailJson; json["emails"]) {
                Email email;
                if ("value" in emailJson) email.value = emailJson["value"].get!string;
                if ("type" in emailJson) email.type = emailJson["type"].get!string;
                if ("primary" in emailJson) email.primary = emailJson["primary"].get!bool;
                user.emails ~= email;
            }
        }
        
        if ("phoneNumbers" in json && json["phoneNumbers"].type == Json.Type.array) {
            foreach (phoneJson; json["phoneNumbers"]) {
                PhoneNumber phone;
                if ("value" in phoneJson) phone.value = phoneJson["value"].get!string;
                if ("type" in phoneJson) phone.type = phoneJson["type"].get!string;
                if ("primary" in phoneJson) phone.primary = phoneJson["primary"].get!bool;
                user.phoneNumbers ~= phone;
            }
        }
        
        return user;
    }
    
    /**
     * Get primary email
     */
    string getPrimaryEmail() const pure @safe {
        foreach (email; emails) {
            if (email.primary) {
                return email.value;
            }
        }
        return emails.length > 0 ? emails[0].value : "";
    }
}

/**
 * User creation request
 */
struct CreateUserRequest {
    string userName;
    string password;
    string givenName;
    string familyName;
    string email;
    bool active = true;
    
    User toUser() const pure @safe {
        User user;
        user.userName = userName;
        user.password = password;
        user.name.givenName = givenName;
        user.name.familyName = familyName;
        user.active = active;
        
        if (email.length > 0) {
            Email emailObj;
            emailObj.value = email;
            emailObj.type = "work";
            emailObj.primary = true;
            user.emails ~= emailObj;
        }
        
        return user;
    }
}

/**
 * User update request
 */
struct UpdateUserRequest {
    string givenName;
    string familyName;
    string displayName;
    string email;
    string phoneNumber;
    bool active;
}
