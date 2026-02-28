module uim.sap.con.helpers.helper;

bool isSupportedProtocol(string protocol) {
    return CON_SUPPORTED_PROTOCOLS.canFind(normalizeProtocol(protocol));
}

string normalizeProtocol(string protocol) {
    return toLower(protocol);
}

ushort defaultPortForProtocol(string protocol) {
    final switch (normalizeProtocol(protocol)) {
        case "http": return 80;
        case "rfc": return 3300;
        case "tcp": return 443;
        case "jdbc": return 5432;
        case "odbc": return 1433;
    }
}
