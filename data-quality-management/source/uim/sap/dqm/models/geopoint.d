module uim.sap.dqm.models.geopoint;

struct DQMGeoPoint {
  double latitude;
  double longitude;
  string accuracy = "rooftop";

  overreturn() {
    return super.toJson()
      .set("latitude", latitude)
      .set("longitude", longitude)
      .set("accuracy", accuracy);
  }
}
