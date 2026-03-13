module uim.sap.cpi.config;

import uim.sap.cpi;

mixin(ShowModule!());

@safe:

enum CPIAuthType {
  Basic,
  OAuth2,
  ApiKey
}

class CPIConfig : SAPConfig {
  mixin(SAPConfigTemplate!CPIConfig);

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }

    baseUrl(initData.getString("baseUrl", ""));
    port(cast(ushort)initData.getInteger("port", 443));
    useSSL(initData.getBool("useSSL", true));
    verifySSL(initData.getBool("verifySSL", true));

    auto authTypeStr = initData.getString("authType", "Basic");
    if (authTypeStr == "Basic") {
      authType(CPIAuthType.Basic);
      username(initData.getString("username", ""));
      password(initData.getString("password", ""));
    } else if (authTypeStr == "OAuth2") {
      authType(CPIAuthType.OAuth2);
      accessToken(initData.getString("accessToken", ""));
    } else if (authTypeStr == "ApiKey") {
      authType(CPIAuthType.ApiKey);
      apiKey(initData.getString("apiKey", ""));
      apiKeyHeader(initData.getString("apiKeyHeader", "X-API-Key"));
    } else {
      throw new CPIConfigurationException("Invalid authType: " ~ authTypeStr);
    }   
    apiBasePath(initData.getString("apiBasePath", "/api/v1"));
    timeout(initData.getDuration("timeout", 30.seconds));
    maxRetries(initData.getInteger("maxRetries", 2));
    customHeaders(initData.getObject("customHeaders", new JsonObject).toStringMap());
  }
  
  string baseUrl;
  ushort port = 443;
  bool useSSL = true;
  bool verifySSL = true;

  CPIAuthType authType = CPIAuthType.Basic;
  string username;
  string password;
  string accessToken;
  string apiKey;
  string apiKeyHeader = "X-API-Key";

  string apiBasePath = "/api/v1";
  Duration timeout = 30.seconds;
  uint maxRetries = 2;

  string[string] customHeaders;

  override void validate() const {
    if (baseUrl.length == 0) {
      throw new CPIConfigurationException("Base URL cannot be empty");
    }

    final switch (authType) {
    case CPIAuthType.Basic:
      if (username.length == 0 || password.length == 0) {
        throw new CPIConfigurationException(
          "Username and password are required for Basic authentication"
        );
      }
      break;
    case CPIAuthType.OAuth2:
      if (accessToken.length == 0) {
        throw new CPIConfigurationException(
          "Access token is required for OAuth2 authentication"
        );
      }
      break;
    case CPIAuthType.ApiKey:
      if (apiKey.length == 0) {
        throw new CPIConfigurationException(
          "API key is required for API key authentication"
        );
      }
      break;
    }
  }

  string fullBaseUrl() const {
    if (baseUrl.startsWith("https://") || baseUrl.startsWith("http://")) {
      return stripTrailingSlash(baseUrl).idup;
    }

    auto protocol = useSSL ? "https" : "http";
    if ((useSSL && port == 443) || (!useSSL && port == 80)) {
      return format("%s://%s", protocol, stripTrailingSlash(baseUrl));
    }

    return format("%s://%s:%d", protocol, stripTrailingSlash(baseUrl), port);
  }

  string apiBaseUrl() const {
    auto path = (apiBasePath.length > 0 ? apiBasePath : "/api/v1").idup;
    if (!path.startsWith("/")) {
      path = "/" ~ path;
    }
    return (fullBaseUrl() ~ path).idup;
  }

  static CPIConfig createBasic(string baseUrl, string username, string password) {
    CPIConfig cfg;
    cfg.baseUrl = baseUrl;
    cfg.username = username;
    cfg.password = password;
    cfg.authType = CPIAuthType.Basic;
    return cfg;
  }

  static CPIConfig createOAuth2(string baseUrl, string accessToken) {
    CPIConfig cfg;
    cfg.baseUrl = baseUrl;
    cfg.accessToken = accessToken;
    cfg.authType = CPIAuthType.OAuth2;
    return cfg;
  }

  private static string stripTrailingSlash(string value) {
    auto result = value;
    while (result.length > 0 && result[$ - 1] == '/') {
      result = result[0 .. $ - 1];
    }
    return result.idup;
  }
}
