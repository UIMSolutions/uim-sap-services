module uim.sap.dqm.store;

import std.algorithm.searching : canFind;
import std.datetime : Clock;
import std.math : fabs;
import std.string : toLower;

import uim.sap.dqm.models;

class DQMStore : SAPStore {
    private DQMGeoRecord[] _records;

    this() {
        seed();
    }

    DQMGeoRecord[] records() {
        return _records;
    }

    DQMGeoRecord[] findAddressMatches(string query, string country) {
        DQMGeoRecord[] matches;
        auto normalizedQuery = toLower(query);
        auto normalizedCountry = toLower(country);

        foreach (record; _records) {
            auto text = toLower(record.address.line1 ~ " " ~ record.address.city ~ " " ~ record.address.postalCode);
            if (text.canFind(normalizedQuery) && toLower(record.address.country) == normalizedCountry) {
                matches ~= record;
            }
        }
        return matches;
    }

    DQMGeoRecord[] suggest(string query, string country, size_t limit = 5) {
        if (query.length == 0) return [];
        auto normalizedQuery = toLower(query);
        auto normalizedCountry = toLower(country);

        DQMGeoRecord[] candidates;
        foreach (record; _records) {
            auto text = toLower(record.address.line1 ~ " " ~ record.address.city);
            if (text.canFind(normalizedQuery) && (country.length == 0 || toLower(record.address.country) == normalizedCountry)) {
                candidates ~= record;
            }
        }

        if (candidates.length > limit) {
            return candidates[0 .. limit];
        }
        return candidates;
    }

    DQMGeoRecord[] nearest(double latitude, double longitude, size_t limit = 3) {
        DQMGeoRecord[] sorted = _records.dup;
        for (size_t i = 0; i < sorted.length; ++i) {
            for (size_t j = i + 1; j < sorted.length; ++j) {
                if (distance(sorted[j].point.latitude, sorted[j].point.longitude, latitude, longitude)
                    < distance(sorted[i].point.latitude, sorted[i].point.longitude, latitude, longitude)) {
                    auto tmp = sorted[i];
                    sorted[i] = sorted[j];
                    sorted[j] = tmp;
                }
            }
        }

        if (sorted.length > limit) {
            return sorted[0 .. limit];
        }
        return sorted;
    }

    private double distance(double lat1, double lon1, double lat2, double lon2) {
        return fabs(lat1 - lat2) + fabs(lon1 - lon2);
    }

    private void seed() {
        DQMGeoRecord[] list;

        list ~= DQMGeoRecord(
            DQMAddress("Friedrichstraße 100", "", "Berlin", "10117", "Berlin", "DE"),
            DQMGeoPoint(52.5208, 13.3862, "rooftop"),
            Clock.currTime()
        );

        list ~= DQMGeoRecord(
            DQMAddress("Friedrichstraße 10", "", "Berlin", "10117", "Berlin", "DE"),
            DQMGeoPoint(52.5186, 13.3889, "rooftop"),
            Clock.currTime()
        );

        list ~= DQMGeoRecord(
            DQMAddress("Dietmar-Hopp-Allee 16", "", "Walldorf", "69190", "Baden-Württemberg", "DE"),
            DQMGeoPoint(49.2936, 8.6424, "rooftop"),
            Clock.currTime()
        );

        list ~= DQMGeoRecord(
            DQMAddress("5 Hanover Quay", "", "Dublin", "D02 VY79", "Leinster", "IE"),
            DQMGeoPoint(53.3440, -6.2375, "street"),
            Clock.currTime()
        );

        _records = list;
    }
}
