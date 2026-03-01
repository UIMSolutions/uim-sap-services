/**
 * Fiori personalization services
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.personalization;

import vibe.d;
import uim.sap.fiori.models;
import uim.sap.fiori.exceptions;
import std.conv : to;

/**
 * Personalization variant
 */
struct Variant {
    string name;
    string key;
    Json data;
    bool isDefault;
}

/**
 * Personalization service
 */
class PersonalizationService : SAPService {
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
     * Get user personalization settings
     */
    PersonalizationSettings getSettings() {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/INTEROP/PersonalizationSettings";
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
                throw new FioriException("Failed to fetch personalization settings");
            }
            
            auto json = res.readJson();
            return parseSettings(json);
        } catch (Exception e) {
            throw new FioriException("Failed to fetch personalization settings: " ~ e.msg);
        }
    }
    
    /**
     * Update user personalization settings
     */
    void updateSettings(PersonalizationSettings settings) {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/INTEROP/PersonalizationSettings";
        auto headers = buildHeaders();
        headers["Content-Type"] = "application/json";
        
        Json data = serializeSettings(settings);
        
        try {
            auto res = httpClient.request((scope req) {
                req.method = HTTPMethod.PUT;
                req.requestURL = url;
                foreach (key, value; headers) {
                    req.headers[key] = value;
                }
                req.writeJsonBody(data);
            });
            
            if (res.statusCode >= 400) {
                throw new FioriException("Failed to update personalization settings");
            }
        } catch (Exception e) {
            throw new FioriException("Failed to update personalization settings: " ~ e.msg);
        }
    }
    
    /**
     * Get variant for a container
     */
    Variant getVariant(string containerId, string variantKey) {
        auto url = config.launchpadBaseUrl() ~ 
                   "/sap/opu/odata/UI2/INTEROP/Variants(ContainerId='" ~ containerId ~ 
                   "',VariantKey='" ~ variantKey ~ "')";
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
                throw new FioriException("Failed to fetch variant");
            }
            
            auto json = res.readJson();
            return parseVariant(json);
        } catch (Exception e) {
            throw new FioriException("Failed to fetch variant: " ~ e.msg);
        }
    }
    
    /**
     * Save variant
     */
    void saveVariant(string containerId, Variant variant) {
        auto url = config.launchpadBaseUrl() ~ "/sap/opu/odata/UI2/INTEROP/Variants";
        auto headers = buildHeaders();
        headers["Content-Type"] = "application/json";
        
        Json data = Json.emptyObject;
        data["ContainerId"] = containerId;
        data["VariantKey"] = variant.key;
        data["VariantName"] = variant.name;
        data["VariantData"] = variant.data.toString();
        data["IsDefault"] = variant.isDefault;
        
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
                throw new FioriException("Failed to save variant");
            }
        } catch (Exception e) {
            throw new FioriException("Failed to save variant: " ~ e.msg);
        }
    }
    
    /**
     * Delete variant
     */
    void deleteVariant(string containerId, string variantKey) {
        auto url = config.launchpadBaseUrl() ~ 
                   "/sap/opu/odata/UI2/INTEROP/Variants(ContainerId='" ~ containerId ~ 
                   "',VariantKey='" ~ variantKey ~ "')";
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
                throw new FioriException("Failed to delete variant");
            }
        } catch (Exception e) {
            throw new FioriException("Failed to delete variant: " ~ e.msg);
        }
    }
    
    /**
     * Get all variants for container
     */
    Variant[] getVariants(string containerId) {
        auto url = config.launchpadBaseUrl() ~ 
                   "/sap/opu/odata/UI2/INTEROP/Variants?$filter=ContainerId eq '" ~ containerId ~ "'";
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
                throw new FioriException("Failed to fetch variants");
            }
            
            auto json = res.readJson();
            return parseVariants(json);
        } catch (Exception e) {
            throw new FioriException("Failed to fetch variants: " ~ e.msg);
        }
    }
    
    private string[string] buildHeaders() {
        string[string] headers;
        headers["Accept"] = "application/json";
        
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
        
        return headers;
    }
    
    private PersonalizationSettings parseSettings(Json json) {
        PersonalizationSettings settings;
        
        if ("d" in json) {
            auto d = json["d"];
            if ("Theme" in d) settings.theme = d["Theme"].get!string;
            if ("Language" in d) settings.language = d["Language"].get!string;
            if ("DateFormat" in d) settings.dateFormat = d["DateFormat"].get!string;
            if ("TimeFormat" in d) settings.timeFormat = d["TimeFormat"].get!string;
        }
        
        return settings;
    }
    
    private Json serializeSettings(PersonalizationSettings settings) {
        Json json = Json.emptyObject;
        json["Theme"] = settings.theme;
        json["Language"] = settings.language;
        json["DateFormat"] = settings.dateFormat;
        json["TimeFormat"] = settings.timeFormat;
        return json;
    }
    
    private Variant parseVariant(Json json) {
        Variant variant;
        
        if ("d" in json) {
            auto d = json["d"];
            if ("VariantName" in d) variant.name = d["VariantName"].get!string;
            if ("VariantKey" in d) variant.key = d["VariantKey"].get!string;
            if ("VariantData" in d) variant.data = parseJsonString(d["VariantData"].get!string);
            if ("IsDefault" in d) variant.isDefault = d["IsDefault"].get!bool;
        }
        
        return variant;
    }
    
    private Variant[] parseVariants(Json json) {
        Variant[] variants;
        
        if ("d" in json && "results" in json["d"]) {
            foreach (item; json["d"]["results"]) {
                variants ~= parseVariant(Json(["d": item]));
            }
        }
        
        return variants;
    }
}
