/**
 * Fiori navigation services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.navigation;

import vibe.d;
import uim.sap.fiori.models;
import uim.sap.fiori.exceptions;
import std.conv : to;
import std.format : format;
import std.array : join;

/**
 * Navigation intent
 */
struct NavigationIntent {
    string semanticObject;
    string action;
    string[string] parameters;
    
    /**
     * Convert to URL hash
     */
    string toHash() const pure @safe {
        auto hash = "#" ~ semanticObject ~ "-" ~ action;
        
        if (parameters.length > 0) {
            string[] params;
            foreach (key, value; parameters) {
                params ~= key ~ "=" ~ value;
            }
            hash ~= "?" ~ params.join("&");
        }
        
        return hash;
    }
}

/**
 * Cross-app navigation service
 */
class NavigationService : SAPService {
    private FioriConfig config;
    
    /**
     * Constructor
     */
    this(FioriConfig config) {
        this.config = config;
    }
    
    /**
     * Create navigation intent
     */
    NavigationIntent createIntent(string semanticObject, string action, string[string] parameters = null) pure @safe {
        NavigationIntent intent;
        intent.semanticObject = semanticObject;
        intent.action = action;
        intent.parameters = parameters;
        return intent;
    }
    
    /**
     * Navigate to intent
     */
    string getNavigationUrl(NavigationIntent intent) const pure @safe {
        return config.launchpadBaseUrl() ~ intent.toHash();
    }
    
    /**
     * Parse intent from hash
     */
    static NavigationIntent parseHash(string hash) {
        import std.string : split, indexOf, strip;
        import std.algorithm : startsWith;
        
        NavigationIntent intent;
        
        if (!hash.startsWith("#")) {
            throw new NavigationException("Invalid hash format: must start with #");
        }
        
        hash = hash[1..$];  // Remove #
        
        auto queryIdx = hash.indexOf('?');
        string intentPart = queryIdx > 0 ? hash[0..queryIdx] : hash;
        string queryPart = queryIdx > 0 ? hash[queryIdx+1..$] : "";
        
        // Parse semantic object and action
        auto parts = intentPart.split('-');
        if (parts.length != 2) {
            throw new NavigationException("Invalid intent format: must be SemanticObject-action");
        }
        
        intent.semanticObject = parts[0];
        intent.action = parts[1];
        
        // Parse parameters
        if (queryPart.length > 0) {
            auto params = queryPart.split('&');
            foreach (param; params) {
                auto kv = param.split('=');
                if (kv.length == 2) {
                    intent.parameters[kv[0]] = kv[1];
                }
            }
        }
        
        return intent;
    }
    
    /**
     * Get supported intents for semantic object
     */
    string[] getSupportedIntents(string semanticObject) {
        // In a real implementation, would query the FLP configuration
        // For now, return common actions
        return ["display", "create", "edit", "delete"];
    }
}

/**
 * Shell service for Fiori shell interactions
 */
class ShellService : SAPService {
    private FioriConfig config;
    
    /**
     * Constructor
     */
    this(FioriConfig config) {
        this.config = config;
    }
    
    /**
     * Set shell title
     */
    void setTitle(string title) {
        // In browser context, would call:
        // sap.ushell.Container.getService("ShellUIService").setTitle(title);
    }
    
    /**
     * Show message in shell
     */
    void showMessage(string message, string type = "Information") {
        // Types: Success, Information, Warning, Error
    }
    
    /**
     * Set back navigation
     */
    void setBackNavigation(NavigationIntent intent) {
        // Configure back button behavior
    }
}
