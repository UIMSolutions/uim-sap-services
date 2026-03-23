module config.tls_config;

import vibe.vibe;

class TLSConfig : SAPConfig {
  mixin(SAPConfigTemplate!TLSConfig);

  string[] protocols;
  string[] cipherSuites;

  TLSConfig loadTLSConfig() {
    auto cfg = new TLSConfig;
    cfg.protocols = ["TLSv1.2", "TLSv1.3"];
    cfg.cipherSuites = [
      "ECDHE-RSA-AES256-GCM-SHA384",
      "ECDHE-RSA-AES128-GCM-SHA256",
      "ECDHE-RSA-AES256-SHA384",
      "ECDHE-RSA-AES128-SHA256"
    ];
    return cfg;
  }
}

void configureTLS() {
  auto tlsConfig = loadTLSConfig();
  // Set the TLS configuration for the server
  // This is a placeholder for actual implementation
  // server.setTLS(tlsConfig.protocols, tlsConfig.cipherSuites);
}
