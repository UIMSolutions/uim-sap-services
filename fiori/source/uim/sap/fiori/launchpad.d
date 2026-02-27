/**
 * Fiori Launchpad client
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.launchpad;

import vibe.d;
import uim.sap.fiori.models;
import uim.sap.fiori.exceptions;
import std.conv : to;

/**
 * Client for Fiori Launchpad APIs
 */
class LaunchpadClient {
    private FioriConfig config;
    private HTTPClient httpClient;
    
    /**
     * Constructor
     */
    this(FioriConfig config) {
        this.config = config;
        this.httpClient = new HTTPClient();
    }
    
    /**
     * Get user's tile groups
     */
    LaunchpadGroup[] getGroups() {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/PageSets";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to fetch groups: HTTP " ~ res.statusCode.to!string);
            }
            
            auto json = res.readJson();
            return parseGroups(json);
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to fetch groups: " ~ e.msg);
        }
    }
    
    /**
     * Get tiles in a group
     */
    LaunchpadTile[] getTiles(string groupId) {
        auto url = config.launchpadBaseUrl() ~ 
                   "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/PageSets('" ~ groupId ~ "')/Pages";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to fetch tiles: HTTP " ~ res.statusCode.to!string);
            }
            
            auto json = res.readJson();
            return parseTiles(json);
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to fetch tiles: " ~ e.msg);
        }
    }
    
    /**
     * Create a new tile group
     */
    LaunchpadGroup createGroup(string title) {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/PageSets";
        auto headers = buildHeaders();
        headers["Content-Type"] = "application/json";
        
        Json data = Json.emptyObject;
        data["title"] = title;
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.POST;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.writeJsonBody(data);
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to create group: HTTP " ~ res.statusCode.to!string);
            }
            
            auto json = res.readJson();
            return parseGroup(json);
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to create group: " ~ e.msg);
        }
    }
    
    /**
     * Add tile to group
     */
    void addTileToGroup(string groupId, LaunchpadTile tile) {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/Pages";
        auto headers = buildHeaders();
        headers["Content-Type"] = "application/json";
        
        Json data = tile.toJson();
        data["pageId"] = groupId;
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.POST;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.writeJsonBody(data);
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to add tile: HTTP " ~ res.statusCode.to!string);
            }
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to add tile: " ~ e.msg);
        }
    }
    
    /**
     * Delete group
     */
    void deleteGroup(string groupId) {
        auto url = config.launchpadBaseUrl() ~ 
                   "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/PageSets('" ~ groupId ~ "')";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.DELETE;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to delete group: HTTP " ~ res.statusCode.to!string);
            }
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to delete group: " ~ e.msg);
        }
    }
    
    /**
     * Get available catalogs
     */
    LaunchpadCatalog[] getCatalogs() {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/PAGE_BUILDER_PERS/Catalogs";
        auto headers = buildHeaders();
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.GET;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
            });
            
            if (res.statusCode >= 400) {
                throw new LaunchpadException("Failed to fetch catalogs: HTTP " ~ res.statusCode.to!string);
            }
            
            auto json = res.readJson();
            return parseCatalogs(json);
        } catch (LaunchpadException e) {
            throw e;
        } catch (Exception e) {
            throw new LaunchpadException("Failed to fetch catalogs: " ~ e.msg);
        }
    }
    
    private string[string] buildHeaders() {
        string[string] headers;
        headers["Accept"] = "application/json";
        
        // Authentication
        final switch (config.authType) {
            case AuthenticationType.Basic:
                import std.base64 : Base64;
                auto credentials = config.username ~ ":" ~ config.password;
                headers["Authorization"] = "Basic " ~ Base64.encode(cast(ubyte[])credentials);
                break;
            case AuthenticationType.OAuth2:
                headers["Authorization"] = "Bearer " ~ config.oauthToken;
                break;
            case AuthenticationType.ApiKey:
                headers["APIKey"] = config.apiKey;
                break;
            case AuthenticationType.SAML:
            case AuthenticationType.Certificate:
                break;
        }
        
        if (config.sapClient.length > 0) {
            headers["sap-client"] = config.sapClient;
        }
        
if (config.sapLanguage.length > 0) {
            headers["sap-language"] = config.sapLanguage;
        }
        
        return headers;
    }
    
    private LaunchpadGroup[] parseGroups(Json json) {
        LaunchpadGroup[] groups;
        
        if ("d" in json && "results" in json["d"]) {
            foreach (item; json["d"]["results"]) {
                groups ~= parseGroup(item);
            }
        }
        
        return groups;
    }
    
    private LaunchpadGroup parseGroup(Json json) {
        LaunchpadGroup group;
        
        if ("id" in json) group.id = json["id"].get!string;
        if ("title" in json) group.title = json["title"].get!string;
        if ("isPreset" in json) group.isPreset = json["isPreset"].get!bool;
        if ("isVisible" in json) group.isVisible = json["isVisible"].get!bool;
        
        return group;
    }
    
    private LaunchpadTile[] parseTiles(Json json) {
        LaunchpadTile[] tiles;
        
        if ("d" in json && "results" in json["d"]) {
            foreach (item; json["d"]["results"]) {
                tiles ~= parseTile(item);
            }
        }
        
        return tiles;
    }
    
    private LaunchpadTile parseTile(Json json) {
        LaunchpadTile tile;
        
        if ("id" in json) tile.id = json["id"].get!string;
        if ("title" in json) tile.title = json["title"].get!string;
        if ("subtitle" in json) tile.subtitle = json["subtitle"].get!string;
        if ("icon" in json) tile.icon = json["icon"].get!string;
        if ("info" in json) tile.info = json["info"].get!string;
        if ("targetUrl" in json) tile.targetUrl = json["targetUrl"].get!string;
        
        return tile;
    }
    
    private LaunchpadCatalog[] parseCatalogs(Json json) {
        LaunchpadCatalog[] catalogs;
        
        if ("d" in json && "results" in json["d"]) {
            foreach (item; json["d"]["results"]) {
                LaunchpadCatalog catalog;
                if ("id" in item) catalog.id = item["id"].get!string;
                if ("title" in item) catalog.title = item["title"].get!string;
                if ("description" in item) catalog.description = item["description"].get!string;
                catalogs ~= catalog;
            }
        }
        
        return catalogs;
    }
}
