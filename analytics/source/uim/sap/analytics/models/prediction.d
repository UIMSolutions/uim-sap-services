/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.sap.analytics.models.prediction;
import uim.sap.analytics;

mixin(ShowModule!());

@safe:

class AnalyticsPrediction : SAPTenantObject {
  mixin(SAPTenantObjectTemplate!AnalyticsPrediction);

  string predictionId;
  string name;
  string description;
  string predictionType; // "time_series", "classification", "regression", "clustering"
  string modelId;        // linked data model
  string status;         // "pending", "training", "ready", "failed"
  string algorithm;      // "auto", "arima", "exponential_smoothing", "linear_regression"
  Json inputColumns;     // columns used as input features
  string targetColumn;   // column to predict
  int horizonPeriods;    // forecast horizon for time series
  double confidence;     // confidence level (0.0 - 1.0)
  Json results;          // prediction results / output
  Json metrics;          // accuracy metrics (MAPE, RMSE, R2)
  SysTime createdAt;
  SysTime completedAt;

  override Json toJson() {
    return super.toJson()
      .set("prediction_id", predictionId)
      .set("name", name)
      .set("description", description)
      .set("prediction_type", predictionType)
      .set("model_id", modelId)
      .set("status", status)
      .set("algorithm", algorithm)
      .set("input_columns", inputColumns)
      .set("target_column", targetColumn)
      .set("horizon_periods", horizonPeriods)
      .set("confidence", confidence)
      .set("results", results)
      .set("metrics", metrics)
      .set("created_at", createdAt.toISOExtString())
      .set("completed_at", completedAt.toISOExtString());
  }
}
