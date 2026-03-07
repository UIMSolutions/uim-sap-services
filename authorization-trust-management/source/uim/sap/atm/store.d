/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.atm.store;

import core.sync.mutex : Mutex;

import uim.sap.atm;

mixin(ShowModule!());

@safe:

class ATMStore : SAPStore {
  private ATMIdentityProvider[string] _idps;
  private ATMTechnicalRole[string] _technicalRoles;
  private ATMRoleCollection[string] _roleCollections;
  private ATMUserAssignment[string] _userAssignments;

  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  ATMIdentityProvider upsertIdp(ATMIdentityProvider idp) {
    synchronized (_lock) {
      auto key = idpKey(idp.tenantId, idp.idpId);
      _idps[key] = idp;

      if (idp.isDefault) {
        clearDefaultIdpInternal(idp.tenantId, idp.idpId);
      }
      return idp;
    }
  }

  ATMIdentityProvider getIdp(string tenantId, string idpId) {
    synchronized (_lock) {
      auto key = idpKey(tenantId, idpId);
      if (auto item = key in _idps) {
        return *item;
      }
    }
    return ATMIdentityProvider.init;
  }

  ATMIdentityProvider[] listIdps(string tenantId) {
    ATMIdentityProvider[] result;
    synchronized (_lock) {
      foreach (key, item; _idps) {
        if (belongsToTenant(key, tenantId)) {
          result ~= item;
        }
      }
    }
    return result;
  }

  ATMIdentityProvider findIdpByIssuer(string tenantId, string issuer) {
    synchronized (_lock) {
      foreach (key, item; _idps) {
        if (!belongsToTenant(key, tenantId)) {
          continue;
        }
        if (item.enabled && item.issuer == issuer) {
          return item;
        }
      }
    }
    return ATMIdentityProvider.init;
  }

  ATMIdentityProvider getDefaultIdp(string tenantId) {
    synchronized (_lock) {
      foreach (key, item; _idps) {
        if (!belongsToTenant(key, tenantId)) {
          continue;
        }
        if (item.enabled && item.isDefault) {
          return item;
        }
      }
    }
    return ATMIdentityProvider.init;
  }

  ATMIdentityProvider setDefaultIdp(string tenantId, string idpId) {
    synchronized (_lock) {
      auto key = idpKey(tenantId, idpId);
      if (auto item = key in _idps) {
        auto idp = *item;
        idp.isDefault = true;
        _idps[key] = idp;
        clearDefaultIdpInternal(tenantId, idpId);
        return idp;
      }
    }
    return ATMIdentityProvider.init;
  }

  ATMTechnicalRole upsertTechnicalRole(ATMTechnicalRole role) {
    synchronized (_lock) {
      auto key = technicalRoleKey(role.tenantId, role.roleId);
      _technicalRoles[key] = role;
      return role;
    }
  }

  ATMTechnicalRole getTechnicalRole(string tenantId, string roleId) {
    synchronized (_lock) {
      auto key = technicalRoleKey(tenantId, roleId);
      if (auto item = key in _technicalRoles) {
        return *item;
      }
    }
    return ATMTechnicalRole.init;
  }

  ATMTechnicalRole[] listTechnicalRoles(string tenantId) {
    ATMTechnicalRole[] result;
    synchronized (_lock) {
      foreach (key, item; _technicalRoles) {
        if (belongsToTenant(key, tenantId)) {
          result ~= item;
        }
      }
    }
    return result;
  }

  ATMRoleCollection upsertRoleCollection(ATMRoleCollection collection) {
    synchronized (_lock) {
      auto key = roleCollectionKey(collection.tenantId, collection.collectionId);
      _roleCollections[key] = collection;
      return collection;
    }
  }

  ATMRoleCollection getRoleCollection(string tenantId, string collectionId) {
    synchronized (_lock) {
      auto key = roleCollectionKey(tenantId, collectionId);
      if (auto item = key in _roleCollections) {
        return *item;
      }
    }
    return ATMRoleCollection.init;
  }

  ATMRoleCollection[] listRoleCollections(string tenantId) {
    ATMRoleCollection[] result;
    synchronized (_lock) {
      foreach (key, item; _roleCollections) {
        if (belongsToTenant(key, tenantId)) {
          result ~= item;
        }
      }
    }
    return result;
  }

  ATMUserAssignment upsertUserAssignment(ATMUserAssignment assignment) {
    synchronized (_lock) {
      auto key = userAssignmentKey(assignment.tenantId, assignment.userId);
      _userAssignments[key] = assignment;
      return assignment;
    }
  }

  ATMUserAssignment getUserAssignment(string tenantId, string userId) {
    synchronized (_lock) {
      auto key = userAssignmentKey(tenantId, userId);
      if (auto item = key in _userAssignments) {
        return *item;
      }
    }
    return ATMUserAssignment.init;
  }

  private void clearDefaultIdpInternal(string tenantId, string exemptIdpId) {
    foreach (key, item; _idps) {
      if (!belongsToTenant(key, tenantId)) {
        continue;
      }
      if (item.idpId == exemptIdpId) {
        continue;
      }
      if (item.isDefault) {
        item.isDefault = false;
        _idps[key] = item;
      }
    }
  }

  private string idpKey(string tenantId, string idpId) {
    return tenantId ~ ":idp:" ~ idpId;
  }

  private string technicalRoleKey(string tenantId, string roleId) {
    return tenantId ~ ":tech-role:" ~ roleId;
  }

  private string roleCollectionKey(string tenantId, string collectionId) {
    return tenantId ~ ":role-collection:" ~ collectionId;
  }

  private string userAssignmentKey(string tenantId, string userId) {
    return tenantId ~ ":user-assignment:" ~ userId;
  }

  private bool belongsToTenant(string key, string tenantId) {
    return key.length > tenantId.length + 1
      && key[0 .. tenantId.length] == tenantId
      && key[tenantId.length] == ':';
  }
}
