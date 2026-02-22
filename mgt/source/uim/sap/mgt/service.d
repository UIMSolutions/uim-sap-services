module uim.sap.mgt.service;

import std.json : StdJson = Json;

import vibe.data.json : Json, parseJsonString;

import uim.sap.btp : SAPBTPClient, listApplications, listDestinations, listOrganizations, listServiceInstances, listServices, listSpaces, getApplication, getDestination, getEnvironment, getSubaccounts;
import uim.sap.mgt.config;
import uim.sap.mgt.exceptions;

class MGTService {
    private MGTConfig _config;
    private SAPBTPClient _client;

    this(MGTConfig config) {
        config.validate();
        _config = config;
        _client = new SAPBTPClient(config.toSAPBTPConfig());
    }

    @property const(MGTConfig) config() const {
        return _config;
    }

    Json health() {
        Json payload = Json.emptyObject;
        payload["ok"] = true;
        payload["serviceName"] = _config.serviceName;
        payload["serviceVersion"] = _config.serviceVersion;
        payload["subdomain"] = _config.subdomain;
        payload["region"] = _config.region;
        return payload;
    }

    Json ready() {
        Json payload = Json.emptyObject;
        payload["ready"] = true;
        return payload;
    }

    Json environments() {
        return toVibeJson(getEnvironment(_client));
    }

    Json subaccounts() {
        return toVibeJson(getSubaccounts(_client));
    }

    Json organizations() {
        return toVibeJson(listOrganizations(_client));
    }

    Json spaces() {
        return toVibeJson(listSpaces(_client));
    }

    Json applications() {
        return toVibeJson(listApplications(_client));
    }

    Json application(string guid) {
        if (guid.length == 0) {
            throw new MGTUpstreamException("Application GUID cannot be empty");
        }
        return toVibeJson(getApplication(_client, guid));
    }

    Json services() {
        return toVibeJson(listServices(_client));
    }

    Json serviceInstances() {
        return toVibeJson(listServiceInstances(_client));
    }

    Json destinations() {
        return toVibeJson(listDestinations(_client));
    }

    Json destination(string name) {
        if (name.length == 0) {
            throw new MGTUpstreamException("Destination name cannot be empty");
        }
        return toVibeJson(getDestination(_client, name));
    }

    private Json toVibeJson(StdJson payload) {
        return parseJsonString(payload.toString());
    }
}
