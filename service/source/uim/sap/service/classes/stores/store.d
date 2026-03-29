module uim.sap.service.classes.stores.store;

import core.sync.mutex : Mutex;
import uim.sap.service;

mixin(ShowModule!());

@safe:

class SAPStore {

  protected Mutex _lock;

  this() {
    initialize();
  }

  this(Json initData) {
    if (initData.isObject) {
      initialize(initData.toMap);
    }
  }

  this(Json[string] initData) {
    initialize(initData);
  }


  bool initialize(Json[string] initData = null) {
    _lock = new Mutex;
    // Initialization logic for the store
    return true;
  }
}
