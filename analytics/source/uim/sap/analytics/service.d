/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.service;

import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsService : SAPService {
  mixin(SAPServiceTemplate!AnalyticsService);

  private AnalyticsStore _store;

  this(AnalyticsConfig config) {
    super(config);
    _store = new AnalyticsStore;
  }

  // ─── Stories (User Experience) ─────────────────────────────────────

  Json createStory(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto story = new AnalyticsStory;
    story.tenantId = tenantId;
    story.storyId = generateId("story");
    story.title = request.getStr("title", "Untitled Story");
    story.description = request.getStr("description", "");
    story.storyType = toLower(request.getStr("story_type", "canvas"));
    story.status = "draft";
    story.createdBy = request.getStr("created_by", "system");
    story.createdAt = Clock.currTime();
    story.updatedAt = Clock.currTime();

    if (!isValidStoryType(story.storyType)) {
      throw new AnalyticsValidationException(
        "Invalid story_type. Must be one of: canvas, responsive, optimized");
    }

    if ("pages" in request && request["pages"].type == Json.Type.array) {
      foreach (page; request["pages"]) {
        story.pages ~= page;
      }
    }

    story.sharing = ("sharing" in request) ? request["sharing"] : Json.emptyObject;

    auto saved = _store.appendStory(story);
    return Json.emptyObject
      .set("success", true)
      .set("story", saved.toJson());
  }

  Json listStories(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto stories = _store.listStories(tenantId);

    Json resources = Json.emptyArray;
    if (stories !is null) {
      foreach (story; stories) {
        resources ~= story.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getStory(string tenantId, string storyId) {
    validateId(tenantId, "Tenant ID");
    auto story = _store.getStory(tenantId, storyId);
    if (story is null) {
      throw new AnalyticsNotFoundException("Story", storyId);
    }
    return Json.emptyObject.set("story", story.toJson());
  }

  Json updateStory(string tenantId, string storyId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto existing = _store.getStory(tenantId, storyId);
    if (existing is null) {
      throw new AnalyticsNotFoundException("Story", storyId);
    }

    if ("title" in request) existing.title = request["title"].get!string;
    if ("description" in request) existing.description = request["description"].get!string;
    if ("status" in request) existing.status = toLower(request["status"].get!string);
    if ("story_type" in request) {
      auto newType = toLower(request["story_type"].get!string);
      if (!isValidStoryType(newType)) {
        throw new AnalyticsValidationException("Invalid story_type");
      }
      existing.storyType = newType;
    }
    if ("pages" in request && request["pages"].type == Json.Type.array) {
      existing.pages = null;
      foreach (page; request["pages"]) {
        existing.pages ~= page;
      }
    }
    if ("sharing" in request) existing.sharing = request["sharing"];
    existing.updatedAt = Clock.currTime();

    auto saved = _store.updateStory(tenantId, storyId, existing);
    return Json.emptyObject
      .set("success", true)
      .set("story", saved.toJson());
  }

  Json deleteStory(string tenantId, string storyId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteStory(tenantId, storyId)) {
      throw new AnalyticsNotFoundException("Story", storyId);
    }
    return Json.emptyObject.set("success", true).set("deleted", storyId);
  }

  // ─── Dashboards (Interactive) ──────────────────────────────────────

  Json createDashboard(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto dashboard = new AnalyticsDashboard;
    dashboard.tenantId = tenantId;
    dashboard.dashboardId = generateId("dash");
    dashboard.title = request.getStr("title", "Untitled Dashboard");
    dashboard.description = request.getStr("description", "");
    dashboard.layout = toLower(request.getStr("layout", "grid"));
    dashboard.status = "draft";
    dashboard.createdBy = request.getStr("created_by", "system");
    dashboard.isInteractive = true;
    dashboard.createdAt = Clock.currTime();
    dashboard.updatedAt = Clock.currTime();

    if (!isValidDashboardLayout(dashboard.layout)) {
      throw new AnalyticsValidationException(
        "Invalid layout. Must be one of: grid, freeform, responsive");
    }

    if ("widgets" in request && request["widgets"].type == Json.Type.array) {
      foreach (widget; request["widgets"]) {
        dashboard.widgets ~= widget;
      }
    }

    dashboard.filters = ("filters" in request) ? request["filters"] : Json.emptyObject;

    auto saved = _store.appendDashboard(dashboard);
    return Json.emptyObject
      .set("success", true)
      .set("dashboard", saved.toJson());
  }

  Json listDashboards(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto dashboards = _store.listDashboards(tenantId);

    Json resources = Json.emptyArray;
    if (dashboards !is null) {
      foreach (dashboard; dashboards) {
        resources ~= dashboard.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getDashboard(string tenantId, string dashboardId) {
    validateId(tenantId, "Tenant ID");
    auto dashboard = _store.getDashboard(tenantId, dashboardId);
    if (dashboard is null) {
      throw new AnalyticsNotFoundException("Dashboard", dashboardId);
    }
    return Json.emptyObject.set("dashboard", dashboard.toJson());
  }

  Json updateDashboard(string tenantId, string dashboardId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto existing = _store.getDashboard(tenantId, dashboardId);
    if (existing is null) {
      throw new AnalyticsNotFoundException("Dashboard", dashboardId);
    }

    if ("title" in request) existing.title = request["title"].get!string;
    if ("description" in request) existing.description = request["description"].get!string;
    if ("layout" in request) {
      auto newLayout = toLower(request["layout"].get!string);
      if (!isValidDashboardLayout(newLayout)) {
        throw new AnalyticsValidationException("Invalid layout");
      }
      existing.layout = newLayout;
    }
    if ("status" in request) existing.status = toLower(request["status"].get!string);
    if ("widgets" in request && request["widgets"].type == Json.Type.array) {
      existing.widgets = null;
      foreach (widget; request["widgets"]) {
        existing.widgets ~= widget;
      }
    }
    if ("filters" in request) existing.filters = request["filters"];
    existing.updatedAt = Clock.currTime();

    auto saved = _store.updateDashboard(tenantId, dashboardId, existing);
    return Json.emptyObject
      .set("success", true)
      .set("dashboard", saved.toJson());
  }

  Json deleteDashboard(string tenantId, string dashboardId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteDashboard(tenantId, dashboardId)) {
      throw new AnalyticsNotFoundException("Dashboard", dashboardId);
    }
    return Json.emptyObject.set("success", true).set("deleted", dashboardId);
  }

  // ─── Datasets (Data Connectivity) ─────────────────────────────────

  Json createDataset(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto dataset = new AnalyticsDataset;
    dataset.tenantId = tenantId;
    dataset.datasetId = generateId("ds");
    dataset.name = request.getStr("name", "Untitled Dataset");
    dataset.description = request.getStr("description", "");
    dataset.sourceType = toLower(request.getStr("source_type", "import"));
    dataset.connectionId = request.getStr("connection_id", "");
    dataset.status = "ready";
    dataset.columns = ("columns" in request) ? request["columns"] : Json.emptyObject;
    dataset.importSchedule = ("import_schedule" in request) ? request["import_schedule"] : Json.emptyObject;
    dataset.createdAt = Clock.currTime();
    dataset.updatedAt = Clock.currTime();

    auto saved = _store.appendDataset(dataset);
    return Json.emptyObject
      .set("success", true)
      .set("dataset", saved.toJson());
  }

  Json listDatasets(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto datasets = _store.listDatasets(tenantId);

    Json resources = Json.emptyArray;
    if (datasets !is null) {
      foreach (dataset; datasets) {
        resources ~= dataset.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getDataset(string tenantId, string datasetId) {
    validateId(tenantId, "Tenant ID");
    auto dataset = _store.getDataset(tenantId, datasetId);
    if (dataset is null) {
      throw new AnalyticsNotFoundException("Dataset", datasetId);
    }
    return Json.emptyObject.set("dataset", dataset.toJson());
  }

  Json deleteDataset(string tenantId, string datasetId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteDataset(tenantId, datasetId)) {
      throw new AnalyticsNotFoundException("Dataset", datasetId);
    }
    return Json.emptyObject.set("success", true).set("deleted", datasetId);
  }

  // ─── Data Models (Dimensions, Measures, Hierarchies) ───────────────

  Json createModel(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto model = new AnalyticsDataModel;
    model.tenantId = tenantId;
    model.modelId = generateId("model");
    model.name = request.getStr("name", "Untitled Model");
    model.description = request.getStr("description", "");
    model.modelType = toLower(request.getStr("model_type", "analytic"));
    model.datasetId = request.getStr("dataset_id", "");
    model.status = "active";
    model.createdAt = Clock.currTime();
    model.updatedAt = Clock.currTime();

    if (!isValidModelType(model.modelType)) {
      throw new AnalyticsValidationException(
        "Invalid model_type. Must be one of: planning, analytic, embedded");
    }

    model.dimensions = ("dimensions" in request) ? request["dimensions"] : Json.emptyObject;
    model.measures = ("measures" in request) ? request["measures"] : Json.emptyObject;
    model.hierarchies = ("hierarchies" in request) ? request["hierarchies"] : Json.emptyObject;
    model.variables = ("variables" in request) ? request["variables"] : Json.emptyObject;

    auto saved = _store.appendModel(model);
    return Json.emptyObject
      .set("success", true)
      .set("model", saved.toJson());
  }

  Json listModels(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto models = _store.listModels(tenantId);

    Json resources = Json.emptyArray;
    if (models !is null) {
      foreach (model; models) {
        resources ~= model.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getModel(string tenantId, string modelId) {
    validateId(tenantId, "Tenant ID");
    auto model = _store.getModel(tenantId, modelId);
    if (model is null) {
      throw new AnalyticsNotFoundException("Model", modelId);
    }
    return Json.emptyObject.set("model", model.toJson());
  }

  Json deleteModel(string tenantId, string modelId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteModel(tenantId, modelId)) {
      throw new AnalyticsNotFoundException("Model", modelId);
    }
    return Json.emptyObject.set("success", true).set("deleted", modelId);
  }

  // ─── Connections (Live and Import) ─────────────────────────────────

  Json createConnection(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto conn = new AnalyticsConnection;
    conn.tenantId = tenantId;
    conn.connectionId = generateId("conn");
    conn.name = request.getStr("name", "Untitled Connection");
    conn.description = request.getStr("description", "");
    conn.connectionType = toLower(request.getStr("connection_type", "import"));
    conn.sourceSystem = toLower(request.getStr("source_system", "database"));
    conn.host = request.getStr("host", "");
    conn.port = cast(ushort) request.getLong("port", 443);
    conn.database = request.getStr("database", "");
    conn.schema = request.getStr("schema", "");
    conn.sslEnabled = request.getBool("ssl_enabled", true);
    conn.status = "disconnected";
    conn.metadata = ("metadata" in request) ? request["metadata"] : Json.emptyObject;
    conn.createdAt = Clock.currTime();

    if (!isValidConnectionType(conn.connectionType)) {
      throw new AnalyticsValidationException(
        "Invalid connection_type. Must be one of: live, import, blend");
    }

    if (!isValidSourceSystem(conn.sourceSystem)) {
      throw new AnalyticsValidationException(
        "Invalid source_system. Must be one of: sap_hana, sap_bw, sap_s4hana, sap_datasphere, odata, csv, database");
    }

    auto saved = _store.appendConnection(conn);
    return Json.emptyObject
      .set("success", true)
      .set("connection", saved.toJson());
  }

  Json listConnections(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto connections = _store.listConnections(tenantId);

    Json resources = Json.emptyArray;
    if (connections !is null) {
      foreach (conn; connections) {
        resources ~= conn.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getConnection(string tenantId, string connectionId) {
    validateId(tenantId, "Tenant ID");
    auto conn = _store.getConnection(tenantId, connectionId);
    if (conn is null) {
      throw new AnalyticsNotFoundException("Connection", connectionId);
    }
    return Json.emptyObject.set("connection", conn.toJson());
  }

  Json testConnection(string tenantId, string connectionId) {
    validateId(tenantId, "Tenant ID");
    auto conn = _store.getConnection(tenantId, connectionId);
    if (conn is null) {
      throw new AnalyticsNotFoundException("Connection", connectionId);
    }

    // Simulate connection test
    conn.status = "connected";
    conn.lastTestedAt = Clock.currTime();

    return Json.emptyObject
      .set("success", true)
      .set("connection_id", connectionId)
      .set("status", "connected")
      .set("tested_at", conn.lastTestedAt.toISOExtString());
  }

  Json deleteConnection(string tenantId, string connectionId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteConnection(tenantId, connectionId)) {
      throw new AnalyticsNotFoundException("Connection", connectionId);
    }
    return Json.emptyObject.set("success", true).set("deleted", connectionId);
  }

  // ─── Planning ──────────────────────────────────────────────────────

  Json createPlan(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto plan = new AnalyticsPlan;
    plan.tenantId = tenantId;
    plan.planId = generateId("plan");
    plan.name = request.getStr("name", "Untitled Plan");
    plan.description = request.getStr("description", "");
    plan.modelId = request.getStr("model_id", "");
    plan.planType = toLower(request.getStr("plan_type", "budget"));
    plan.status = "draft";
    plan.createdBy = request.getStr("created_by", "system");
    plan.versions = ("versions" in request) ? request["versions"] : Json.emptyObject;
    plan.cells = ("cells" in request) ? request["cells"] : Json.emptyObject;
    plan.workflows = ("workflows" in request) ? request["workflows"] : Json.emptyObject;
    plan.createdAt = Clock.currTime();
    plan.updatedAt = Clock.currTime();

    if (plan.modelId.length > 0) {
      auto model = _store.getModel(tenantId, plan.modelId);
      if (model is null) {
        throw new AnalyticsValidationException("Referenced model_id does not exist: " ~ plan.modelId);
      }
    }

    auto saved = _store.appendPlan(plan);
    return Json.emptyObject
      .set("success", true)
      .set("plan", saved.toJson());
  }

  Json listPlans(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto plans = _store.listPlans(tenantId);

    Json resources = Json.emptyArray;
    if (plans !is null) {
      foreach (plan; plans) {
        resources ~= plan.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getPlan(string tenantId, string planId) {
    validateId(tenantId, "Tenant ID");
    auto plan = _store.getPlan(tenantId, planId);
    if (plan is null) {
      throw new AnalyticsNotFoundException("Plan", planId);
    }
    return Json.emptyObject.set("plan", plan.toJson());
  }

  Json updatePlan(string tenantId, string planId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto existing = _store.getPlan(tenantId, planId);
    if (existing is null) {
      throw new AnalyticsNotFoundException("Plan", planId);
    }

    if ("name" in request) existing.name = request["name"].get!string;
    if ("description" in request) existing.description = request["description"].get!string;
    if ("status" in request) existing.status = toLower(request["status"].get!string);
    if ("plan_type" in request) existing.planType = toLower(request["plan_type"].get!string);
    if ("cells" in request) existing.cells = request["cells"];
    if ("workflows" in request) existing.workflows = request["workflows"];
    existing.updatedAt = Clock.currTime();

    auto saved = _store.updatePlan(tenantId, planId, existing);
    return Json.emptyObject
      .set("success", true)
      .set("plan", saved.toJson());
  }

  Json deletePlan(string tenantId, string planId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deletePlan(tenantId, planId)) {
      throw new AnalyticsNotFoundException("Plan", planId);
    }
    return Json.emptyObject.set("success", true).set("deleted", planId);
  }

  // ─── Smart Capabilities: What-If Scenarios ─────────────────────────

  Json simulateScenario(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto planId = request.getStr("plan_id", "");
    if (planId.length == 0) {
      throw new AnalyticsValidationException("plan_id is required for scenario simulation");
    }

    auto plan = _store.getPlan(tenantId, planId);
    if (plan is null) {
      throw new AnalyticsNotFoundException("Plan", planId);
    }

    auto scenarioName = request.getStr("scenario_name", "What-If Scenario");
    auto adjustments = ("adjustments" in request) ? request["adjustments"] : Json.emptyObject;

    // Simulate what-if: create a scenario result based on plan data + adjustments
    Json scenarioResult = Json.emptyObject
      .set("scenario_id", generateId("scenario"))
      .set("scenario_name", scenarioName)
      .set("base_plan_id", planId)
      .set("base_plan_name", plan.name)
      .set("adjustments_applied", adjustments)
      .set("status", "completed")
      .set("simulated_at", Clock.currTime().toISOExtString());

    // Generate simulated outcome summary
    Json outcomes = Json.emptyObject
      .set("impact_summary", "Scenario simulation completed based on provided adjustments")
      .set("base_values", plan.cells)
      .set("adjusted_values", adjustments)
      .set("confidence_level", 0.85);

    scenarioResult.set("outcomes", outcomes);

    return Json.emptyObject
      .set("success", true)
      .set("scenario", scenarioResult);
  }

  // ─── Smart Capabilities: Predictions / AutoML ──────────────────────

  Json createPrediction(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto prediction = new AnalyticsPrediction;
    prediction.tenantId = tenantId;
    prediction.predictionId = generateId("pred");
    prediction.name = request.getStr("name", "Untitled Prediction");
    prediction.description = request.getStr("description", "");
    prediction.predictionType = toLower(request.getStr("prediction_type", "time_series"));
    prediction.modelId = request.getStr("model_id", "");
    prediction.algorithm = toLower(request.getStr("algorithm", "auto"));
    prediction.targetColumn = request.getStr("target_column", "");
    prediction.horizonPeriods = cast(int) request.getLong("horizon_periods", 12);
    prediction.confidence = request.getDouble("confidence", 0.95);
    prediction.status = "pending";
    prediction.inputColumns = ("input_columns" in request) ? request["input_columns"] : Json.emptyArray;
    prediction.createdAt = Clock.currTime();

    if (!isValidPredictionType(prediction.predictionType)) {
      throw new AnalyticsValidationException(
        "Invalid prediction_type. Must be one of: time_series, classification, regression, clustering");
    }

    if (prediction.targetColumn.length == 0) {
      throw new AnalyticsValidationException("target_column is required");
    }

    // Simulate training completion
    prediction.status = "ready";
    prediction.completedAt = Clock.currTime();
    prediction.results = Json.emptyObject
      .set("predicted_values", Json.emptyArray)
      .set("horizon_periods", prediction.horizonPeriods)
      .set("algorithm_used", prediction.algorithm == "auto" ? "exponential_smoothing" : prediction.algorithm);

    prediction.metrics = Json.emptyObject
      .set("mape", 0.045)
      .set("rmse", 12.3)
      .set("r_squared", 0.92);

    auto saved = _store.appendPrediction(prediction);
    return Json.emptyObject
      .set("success", true)
      .set("prediction", saved.toJson());
  }

  Json listPredictions(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto predictions = _store.listPredictions(tenantId);

    Json resources = Json.emptyArray;
    if (predictions !is null) {
      foreach (prediction; predictions) {
        resources ~= prediction.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getPrediction(string tenantId, string predictionId) {
    validateId(tenantId, "Tenant ID");
    auto prediction = _store.getPrediction(tenantId, predictionId);
    if (prediction is null) {
      throw new AnalyticsNotFoundException("Prediction", predictionId);
    }
    return Json.emptyObject.set("prediction", prediction.toJson());
  }

  // ─── Ad-Hoc Analysis (Pivot-Table Style) ──────────────────────────

  Json queryAnalysis(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto modelId = request.getStr("model_id", "");
    if (modelId.length == 0) {
      throw new AnalyticsValidationException("model_id is required for ad-hoc analysis");
    }

    auto model = _store.getModel(tenantId, modelId);
    if (model is null) {
      throw new AnalyticsNotFoundException("Model", modelId);
    }

    auto rows = ("rows" in request) ? request["rows"] : Json.emptyArray;
    auto columns = ("columns" in request) ? request["columns"] : Json.emptyArray;
    auto measures = ("measures" in request) ? request["measures"] : Json.emptyArray;
    auto filters = ("filters" in request) ? request["filters"] : Json.emptyObject;

    // Generate analysis result based on model structure
    Json analysisResult = Json.emptyObject
      .set("query_id", generateId("query"))
      .set("model_id", modelId)
      .set("model_name", model.name)
      .set("rows", rows)
      .set("columns", columns)
      .set("measures", measures)
      .set("filters", filters)
      .set("data", Json.emptyArray) // placeholder for aggregated data
      .set("total_rows", cast(long) 0)
      .set("executed_at", Clock.currTime().toISOExtString());

    return Json.emptyObject
      .set("success", true)
      .set("analysis", analysisResult);
  }

  // ─── Administration: Users ─────────────────────────────────────────

  Json createUser(string tenantId, Json request) {
    validateId(tenantId, "Tenant ID");

    auto user = new AnalyticsUser;
    user.tenantId = tenantId;
    user.userId = generateId("user");
    user.userName = request.getStr("user_name", "");
    user.email = request.getStr("email", "");
    user.displayName = request.getStr("display_name", "");
    user.role = toLower(request.getStr("role", "viewer"));
    user.isActive = true;
    user.preferences = ("preferences" in request) ? request["preferences"] : Json.emptyObject;
    user.assignedTeams = ("assigned_teams" in request) ? request["assigned_teams"] : Json.emptyArray;
    user.createdAt = Clock.currTime();
    user.lastLoginAt = Clock.currTime();

    if (user.userName.length == 0) {
      throw new AnalyticsValidationException("user_name is required");
    }

    if (!isValidUserRole(user.role)) {
      throw new AnalyticsValidationException(
        "Invalid role. Must be one of: admin, bi_admin, planner, viewer, creator");
    }

    auto saved = _store.appendUser(user);
    return Json.emptyObject
      .set("success", true)
      .set("user", saved.toJson());
  }

  Json listUsers(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto users = _store.listUsers(tenantId);

    Json resources = Json.emptyArray;
    if (users !is null) {
      foreach (user; users) {
        resources ~= user.toJson();
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resources", resources)
      .set("total_results", cast(long) resources.length);
  }

  Json getUser(string tenantId, string userId) {
    validateId(tenantId, "Tenant ID");
    auto user = _store.getUser(tenantId, userId);
    if (user is null) {
      throw new AnalyticsNotFoundException("User", userId);
    }
    return Json.emptyObject.set("user", user.toJson());
  }

  Json updateUser(string tenantId, string userId, Json request) {
    validateId(tenantId, "Tenant ID");
    auto existing = _store.getUser(tenantId, userId);
    if (existing is null) {
      throw new AnalyticsNotFoundException("User", userId);
    }

    if ("display_name" in request) existing.displayName = request["display_name"].get!string;
    if ("email" in request) existing.email = request["email"].get!string;
    if ("role" in request) {
      auto newRole = toLower(request["role"].get!string);
      if (!isValidUserRole(newRole)) {
        throw new AnalyticsValidationException("Invalid role");
      }
      existing.role = newRole;
    }
    if ("is_active" in request) existing.isActive = request["is_active"].get!bool;
    if ("preferences" in request) existing.preferences = request["preferences"];

    auto saved = _store.updateUser(tenantId, userId, existing);
    return Json.emptyObject
      .set("success", true)
      .set("user", saved.toJson());
  }

  Json deleteUser(string tenantId, string userId) {
    validateId(tenantId, "Tenant ID");
    if (!_store.deleteUser(tenantId, userId)) {
      throw new AnalyticsNotFoundException("User", userId);
    }
    return Json.emptyObject.set("success", true).set("deleted", userId);
  }

  // ─── Administration: Tenant Overview ───────────────────────────────

  Json tenantOverview(string tenantId) {
    validateId(tenantId, "Tenant ID");

    auto stories = _store.listStories(tenantId);
    auto dashboards = _store.listDashboards(tenantId);
    auto datasets = _store.listDatasets(tenantId);
    auto models = _store.listModels(tenantId);
    auto plans = _store.listPlans(tenantId);
    auto predictions = _store.listPredictions(tenantId);
    auto connections = _store.listConnections(tenantId);
    auto users = _store.listUsers(tenantId);

    long connectedCount = 0;
    if (connections !is null) {
      foreach (conn; connections) {
        if (conn.status == "connected") {
          ++connectedCount;
        }
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("stories_count", cast(long)(stories is null ? 0 : stories.length))
      .set("dashboards_count", cast(long)(dashboards is null ? 0 : dashboards.length))
      .set("datasets_count", cast(long)(datasets is null ? 0 : datasets.length))
      .set("models_count", cast(long)(models is null ? 0 : models.length))
      .set("plans_count", cast(long)(plans is null ? 0 : plans.length))
      .set("predictions_count", cast(long)(predictions is null ? 0 : predictions.length))
      .set("connections_count", cast(long)(connections is null ? 0 : connections.length))
      .set("connections_active", connectedCount)
      .set("users_count", cast(long)(users is null ? 0 : users.length));
  }

  // ─── Mobile Access ─────────────────────────────────────────────────

  Json mobileAccess(string tenantId) {
    validateId(tenantId, "Tenant ID");

    // Return mobile-optimized content catalog
    auto stories = _store.listStories(tenantId);
    auto dashboards = _store.listDashboards(tenantId);

    Json mobileStories = Json.emptyArray;
    if (stories !is null) {
      foreach (story; stories) {
        if (story.status == "published") {
          mobileStories ~= Json.emptyObject
            .set("story_id", story.storyId)
            .set("title", story.title)
            .set("story_type", story.storyType)
            .set("updated_at", story.updatedAt.toISOExtString());
        }
      }
    }

    Json mobileDashboards = Json.emptyArray;
    if (dashboards !is null) {
      foreach (dashboard; dashboards) {
        if (dashboard.status == "published") {
          mobileDashboards ~= Json.emptyObject
            .set("dashboard_id", dashboard.dashboardId)
            .set("title", dashboard.title)
            .set("layout", dashboard.layout)
            .set("updated_at", dashboard.updatedAt.toISOExtString());
        }
      }
    }

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("platform", "ios,android")
      .set("stories", mobileStories)
      .set("dashboards", mobileDashboards)
      .set("total_stories", cast(long) mobileStories.length)
      .set("total_dashboards", cast(long) mobileDashboards.length);
  }

  // ─── SAP Datasphere Integration ───────────────────────────────────

  Json datasphereStatus(string tenantId) {
    validateId(tenantId, "Tenant ID");
    auto cfg = cast(AnalyticsConfig) config;

    return Json.emptyObject
      .set("tenant_id", tenantId)
      .set("integration_enabled", cfg.datasphereIntegrationEnabled)
      .set("endpoint", cfg.datasphereEndpoint)
      .set("status", cfg.datasphereIntegrationEnabled ? "available" : "not_configured");
  }

  // ─── Embedding ─────────────────────────────────────────────────────

  Json getEmbedInfo(string tenantId, string resourceType, string resourceId) {
    validateId(tenantId, "Tenant ID");

    Json embedInfo = Json.emptyObject
      .set("tenant_id", tenantId)
      .set("resource_type", resourceType)
      .set("resource_id", resourceId)
      .set("embed_url", "/embed/" ~ resourceType ~ "/" ~ resourceId)
      .set("embed_token", generateId("embed"))
      .set("expires_in_seconds", cast(long) 3600);

    if (resourceType == "story") {
      auto story = _store.getStory(tenantId, resourceId);
      if (story is null) {
        throw new AnalyticsNotFoundException("Story", resourceId);
      }
      embedInfo.set("title", story.title);
    } else if (resourceType == "dashboard") {
      auto dashboard = _store.getDashboard(tenantId, resourceId);
      if (dashboard is null) {
        throw new AnalyticsNotFoundException("Dashboard", resourceId);
      }
      embedInfo.set("title", dashboard.title);
    } else {
      throw new AnalyticsValidationException("resource_type must be 'story' or 'dashboard'");
    }

    return Json.emptyObject
      .set("success", true)
      .set("embed", embedInfo);
  }
}
