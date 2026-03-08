/**
 * Fiori App models
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.models.app;

import vibe.data.json;

/**
 * Fiori application descriptor
 */
struct FioriApp {
    string id;
    string title;
    string description;
    string version_;
    string type;  // application, component, library
    string[] tags;
    AppDataSource[] dataSources;
    string mainServiceUrl;
    Json manifest;
}

/**
 * Application data source
 */
struct AppDataSource {
    string name;
    string uri;
    string type;  // OData, JSON, XML
    string odataVersion;
    AppSettings settings;
}

/**
 * Application settings
 */
struct AppSettings {
    string localUri;
    Json annotations;
}

/**
 * UI5 component configuration
 */
struct UI5ComponentConfig : SAPConfig, ISAPConfig {
    string name;
    string version_;
    string[] dependencies;
    string[] libraries;
}
