/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.store;

import core.sync.mutex : Mutex;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsStore : SAPStore {
  private AnalyticsStory[][string] _storiesByTenant;
  private AnalyticsDashboard[][string] _dashboardsByTenant;
  private AnalyticsDataset[][string] _datasetsByTenant;
  private AnalyticsDataModel[][string] _modelsByTenant;
  private AnalyticsPlan[][string] _plansByTenant;
  private AnalyticsPrediction[][string] _predictionsByTenant;
  private AnalyticsConnection[][string] _connectionsByTenant;
  private AnalyticsUser[][string] _usersByTenant;
  private Mutex _lock;

  this() {
    _lock = new Mutex;
  }

  // --- Stories ---

  AnalyticsStory appendStory(AnalyticsStory story) {
    synchronized (_lock) {
      _storiesByTenant[story.tenantId] ~= story;
      return story;
    }
  }

  AnalyticsStory[] listStories(string tenantId) {
    synchronized (_lock) {
      if (auto stories = tenantId in _storiesByTenant) {
        return (*stories).dup;
      }
    }
    return null;
  }

  AnalyticsStory getStory(string tenantId, string storyId) {
    synchronized (_lock) {
      if (auto stories = tenantId in _storiesByTenant) {
        foreach (story; *stories) {
          if (story.storyId == storyId) {
            return story;
          }
        }
      }
    }
    return null;
  }

  AnalyticsStory updateStory(string tenantId, string storyId, AnalyticsStory updated) {
    synchronized (_lock) {
      if (auto stories = tenantId in _storiesByTenant) {
        foreach (ref story; *stories) {
          if (story.storyId == storyId) {
            story = updated;
            return story;
          }
        }
      }
    }
    return null;
  }

  bool deleteStory(string tenantId, string storyId) {
    synchronized (_lock) {
      if (auto stories = tenantId in _storiesByTenant) {
        AnalyticsStory[] filtered;
        bool found = false;
        foreach (story; *stories) {
          if (story.storyId == storyId) {
            found = true;
          } else {
            filtered ~= story;
          }
        }
        if (found) {
          _storiesByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Dashboards ---

  AnalyticsDashboard appendDashboard(AnalyticsDashboard dashboard) {
    synchronized (_lock) {
      _dashboardsByTenant[dashboard.tenantId] ~= dashboard;
      return dashboard;
    }
  }

  AnalyticsDashboard[] listDashboards(string tenantId) {
    synchronized (_lock) {
      if (auto dashboards = tenantId in _dashboardsByTenant) {
        return (*dashboards).dup;
      }
    }
    return null;
  }

  AnalyticsDashboard getDashboard(string tenantId, string dashboardId) {
    synchronized (_lock) {
      if (auto dashboards = tenantId in _dashboardsByTenant) {
        foreach (dashboard; *dashboards) {
          if (dashboard.dashboardId == dashboardId) {
            return dashboard;
          }
        }
      }
    }
    return null;
  }

  AnalyticsDashboard updateDashboard(string tenantId, string dashboardId, AnalyticsDashboard updated) {
    synchronized (_lock) {
      if (auto dashboards = tenantId in _dashboardsByTenant) {
        foreach (ref dashboard; *dashboards) {
          if (dashboard.dashboardId == dashboardId) {
            dashboard = updated;
            return dashboard;
          }
        }
      }
    }
    return null;
  }

  bool deleteDashboard(string tenantId, string dashboardId) {
    synchronized (_lock) {
      if (auto dashboards = tenantId in _dashboardsByTenant) {
        AnalyticsDashboard[] filtered;
        bool found = false;
        foreach (dashboard; *dashboards) {
          if (dashboard.dashboardId == dashboardId) {
            found = true;
          } else {
            filtered ~= dashboard;
          }
        }
        if (found) {
          _dashboardsByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Datasets ---

  AnalyticsDataset appendDataset(AnalyticsDataset dataset) {
    synchronized (_lock) {
      _datasetsByTenant[dataset.tenantId] ~= dataset;
      return dataset;
    }
  }

  AnalyticsDataset[] listDatasets(string tenantId) {
    synchronized (_lock) {
      if (auto datasets = tenantId in _datasetsByTenant) {
        return (*datasets).dup;
      }
    }
    return null;
  }

  AnalyticsDataset getDataset(string tenantId, string datasetId) {
    synchronized (_lock) {
      if (auto datasets = tenantId in _datasetsByTenant) {
        foreach (dataset; *datasets) {
          if (dataset.datasetId == datasetId) {
            return dataset;
          }
        }
      }
    }
    return null;
  }

  bool deleteDataset(string tenantId, string datasetId) {
    synchronized (_lock) {
      if (auto datasets = tenantId in _datasetsByTenant) {
        AnalyticsDataset[] filtered;
        bool found = false;
        foreach (dataset; *datasets) {
          if (dataset.datasetId == datasetId) {
            found = true;
          } else {
            filtered ~= dataset;
          }
        }
        if (found) {
          _datasetsByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Data Models ---

  AnalyticsDataModel appendModel(AnalyticsDataModel model) {
    synchronized (_lock) {
      _modelsByTenant[model.tenantId] ~= model;
      return model;
    }
  }

  AnalyticsDataModel[] listModels(string tenantId) {
    synchronized (_lock) {
      if (auto models = tenantId in _modelsByTenant) {
        return (*models).dup;
      }
    }
    return null;
  }

  AnalyticsDataModel getModel(string tenantId, string modelId) {
    synchronized (_lock) {
      if (auto models = tenantId in _modelsByTenant) {
        foreach (model; *models) {
          if (model.modelId == modelId) {
            return model;
          }
        }
      }
    }
    return null;
  }

  bool deleteModel(string tenantId, string modelId) {
    synchronized (_lock) {
      if (auto models = tenantId in _modelsByTenant) {
        AnalyticsDataModel[] filtered;
        bool found = false;
        foreach (model; *models) {
          if (model.modelId == modelId) {
            found = true;
          } else {
            filtered ~= model;
          }
        }
        if (found) {
          _modelsByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Plans ---

  AnalyticsPlan appendPlan(AnalyticsPlan plan) {
    synchronized (_lock) {
      _plansByTenant[plan.tenantId] ~= plan;
      return plan;
    }
  }

  AnalyticsPlan[] listPlans(string tenantId) {
    synchronized (_lock) {
      if (auto plans = tenantId in _plansByTenant) {
        return (*plans).dup;
      }
    }
    return null;
  }

  AnalyticsPlan getPlan(string tenantId, string planId) {
    synchronized (_lock) {
      if (auto plans = tenantId in _plansByTenant) {
        foreach (plan; *plans) {
          if (plan.planId == planId) {
            return plan;
          }
        }
      }
    }
    return null;
  }

  AnalyticsPlan updatePlan(string tenantId, string planId, AnalyticsPlan updated) {
    synchronized (_lock) {
      if (auto plans = tenantId in _plansByTenant) {
        foreach (ref plan; *plans) {
          if (plan.planId == planId) {
            plan = updated;
            return plan;
          }
        }
      }
    }
    return null;
  }

  bool deletePlan(string tenantId, string planId) {
    synchronized (_lock) {
      if (auto plans = tenantId in _plansByTenant) {
        AnalyticsPlan[] filtered;
        bool found = false;
        foreach (plan; *plans) {
          if (plan.planId == planId) {
            found = true;
          } else {
            filtered ~= plan;
          }
        }
        if (found) {
          _plansByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Predictions ---

  AnalyticsPrediction appendPrediction(AnalyticsPrediction prediction) {
    synchronized (_lock) {
      _predictionsByTenant[prediction.tenantId] ~= prediction;
      return prediction;
    }
  }

  AnalyticsPrediction[] listPredictions(string tenantId) {
    synchronized (_lock) {
      if (auto predictions = tenantId in _predictionsByTenant) {
        return (*predictions).dup;
      }
    }
    return null;
  }

  AnalyticsPrediction getPrediction(string tenantId, string predictionId) {
    synchronized (_lock) {
      if (auto predictions = tenantId in _predictionsByTenant) {
        foreach (prediction; *predictions) {
          if (prediction.predictionId == predictionId) {
            return prediction;
          }
        }
      }
    }
    return null;
  }

  // --- Connections ---

  AnalyticsConnection appendConnection(AnalyticsConnection connection) {
    synchronized (_lock) {
      _connectionsByTenant[connection.tenantId] ~= connection;
      return connection;
    }
  }

  AnalyticsConnection[] listConnections(string tenantId) {
    synchronized (_lock) {
      if (auto connections = tenantId in _connectionsByTenant) {
        return (*connections).dup;
      }
    }
    return null;
  }

  AnalyticsConnection getConnection(string tenantId, string connectionId) {
    synchronized (_lock) {
      if (auto connections = tenantId in _connectionsByTenant) {
        foreach (connection; *connections) {
          if (connection.connectionId == connectionId) {
            return connection;
          }
        }
      }
    }
    return null;
  }

  bool deleteConnection(string tenantId, string connectionId) {
    synchronized (_lock) {
      if (auto connections = tenantId in _connectionsByTenant) {
        AnalyticsConnection[] filtered;
        bool found = false;
        foreach (connection; *connections) {
          if (connection.connectionId == connectionId) {
            found = true;
          } else {
            filtered ~= connection;
          }
        }
        if (found) {
          _connectionsByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }

  // --- Users ---

  AnalyticsUser appendUser(AnalyticsUser user) {
    synchronized (_lock) {
      _usersByTenant[user.tenantId] ~= user;
      return user;
    }
  }

  AnalyticsUser[] listUsers(string tenantId) {
    synchronized (_lock) {
      if (auto users = tenantId in _usersByTenant) {
        return (*users).dup;
      }
    }
    return null;
  }

  AnalyticsUser getUser(string tenantId, string odataUserId) {
    synchronized (_lock) {
      if (auto users = tenantId in _usersByTenant) {
        foreach (user; *users) {
          if (user.userId == odataUserId) {
            return user;
          }
        }
      }
    }
    return null;
  }

  AnalyticsUser updateUser(string tenantId, string userId, AnalyticsUser updated) {
    synchronized (_lock) {
      if (auto users = tenantId in _usersByTenant) {
        foreach (ref user; *users) {
          if (user.userId == userId) {
            user = updated;
            return user;
          }
        }
      }
    }
    return null;
  }

  bool deleteUser(string tenantId, string userId) {
    synchronized (_lock) {
      if (auto users = tenantId in _usersByTenant) {
        AnalyticsUser[] filtered;
        bool found = false;
        foreach (user; *users) {
          if (user.userId == userId) {
            found = true;
          } else {
            filtered ~= user;
          }
        }
        if (found) {
          _usersByTenant[tenantId] = filtered;
        }
        return found;
      }
    }
    return false;
  }
}
