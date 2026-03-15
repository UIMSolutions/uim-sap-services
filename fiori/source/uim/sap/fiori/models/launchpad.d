/**
 * Launchpad models
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.models.launchpad;

import vibe.data.json;

/**
 * Fiori Launchpad Tile
 */
struct LaunchpadTile {
    string id;
    string title;
    string subtitle;
    string icon;
    string info;
    string infoState;  // Neutral, Positive, Negative, Critical
    string targetUrl;
    string semanticObject;
    string action;
    Json properties;
    
    /**
     * Convert to JSON
     */
    override Json toJson()  {
        Json json = Json.emptyObject;
        json["id"] = id;
        json["title"] = title;
        if (subtitle.length > 0) json["subtitle"] = subtitle;
        if (icon.length > 0) json["icon"] = icon;
        if (info.length > 0) json["info"] = info;
        if (infoState.length > 0) json["infoState"] = infoState;
        if (targetUrl.length > 0) json["targetUrl"] = targetUrl;
        if (semanticObject.length > 0) json["semanticObject"] = semanticObject;
        if (action.length > 0) json["action"] = action;
        return json;
    }
}

/**
 * Fiori Launchpad Group
 */
struct LaunchpadGroup {
    UUID id;
    string title;
    bool isPreset;
    bool isVisible;
    LaunchpadTile[] tiles;
    
    /**
     * Add tile to group
     */
    void addTile(LaunchpadTile tile) pure @safe {
        tiles ~= tile;
    }
}

/**
 * Fiori Launchpad Catalog
 */
struct LaunchpadCatalog {
    string id;
    string title;
    string description;
    LaunchpadTile[] tiles;
}

/**
 * User personalization settings
 */
struct PersonalizationSettings {
    string theme;
    string language;
    string dateFormat;
    string timeFormat;
    string numberFormat;
    Json customSettings;
}

/**
 * Semantic object
 */
struct SemanticObject {
    string name;
    string[] actions;
}
