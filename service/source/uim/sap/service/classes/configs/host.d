/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.service.classes.configs.host;

import core.sync.mutex : Mutex;
import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPHostConfig : SAPConfig {
   mixin(SAPConfigTemplate!SAPHostConfig);

  protected string _host;
  string host() const {
    return _host;
  }

  void host(string value) {
    _host = value;
  }
}
