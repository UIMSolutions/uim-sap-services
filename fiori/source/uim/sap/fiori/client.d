/**
 * Main Fiori client
 * 
 * Copyright: Copyright © 2018-2026, Ozan Nurettin Süel
 * License: Apache-2.0
 * Authors: Ozan Nurettin Süel
 */
module uim.sap.fiori.client;

import vibe.d;
import uim.sap.fiori.models;
import uim.sap.fiori.odata;
import uim.sap.fiori.launchpad;
import uim.sap.fiori.navigation;
import uim.sap.fiori.personalization;
import uim.sap.fiori.exceptions;

/**
 * Main Fiori client
 */
class FioriClient {
  private FioriConfig _config;
  private ODataClient _odata;
  private LaunchpadClient _launchpad;
  private NavigationService _navigation;
  private PersonalizationService _personalization;
  private ShellService _shell;

  /**
     * Constructor
     */
  this(FioriConfig config) {
    config.validate();
    this._config = config;

    // Initialize services
    this._odata = new ODataClient(config);
    this._launchpad = new LaunchpadClient(config);
    this._navigation = new NavigationService(config);
    this._personalization = new PersonalizationService(config);
    this._shell = new ShellService(config);
  }

  /**
     * Get OData client
     */
  @property ODataClient odata() {
    return _odata;
  }

  /**
     * Get Launchpad client
     */
  @property LaunchpadClient launchpad() {
    return _launchpad;
  }

  /**
     * Get navigation service
     */
  @property NavigationService navigation() {
    return _navigation;
  }

  /**
     * Get personalization service
     */
  @property PersonalizationService personalization() {
    return _personalization;
  }

  /**
     * Get shell service
     */
  @property ShellService shell() {
    return _shell;
  }

  /**
     * Get configuration
     */
  @property FioriConfig config() const {
    return _config;
  }

  /**
     * Test connection
     */
  bool testConnection() {
    try {
      _odata.fetchMetadata();
      return true;
    } catch (Exception e) {
      return false;
    }
  }
}
