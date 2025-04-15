//
//  LocationCoordinates.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct LocationCoordinates: Codable {
    var latitude: Double
    var longitude: Double

    // MARK: - Initializer
    init(latitude: Double = 0.0, longitude: Double = 0.0) {
        self.latitude = latitude
        self.longitude = longitude
    }

    // MARK: - Firebase-style Initializer (from [String: Any])
    init?(dict: [String: Any]) {
        self.latitude = 0.0
        self.longitude = 0.0

        if let lat = dict["latitude"] {
            if let latDouble = lat as? Double {
                self.latitude = latDouble
            } else if let latString = lat as? String, let parsed = Double(latString) {
                self.latitude = parsed
            } else {
                print("Invalid latitude format: \(lat)")
            }
        }

        if let lon = dict["longitude"] {
            if let lonDouble = lon as? Double {
                self.longitude = lonDouble
            } else if let lonString = lon as? String, let parsed = Double(lonString) {
                self.longitude = parsed
            } else {
                print("Invalid longitude format: \(lon)")
            }
        }
    }

    // MARK: - Accessors (matching Java-style)
    var latitudeAsDouble: Double {
        return latitude
    }

    var longitudeAsDouble: Double {
        return longitude
    }

    // MARK: - Dictionary conversion (optional for saving to Firebase)
    func toDictionary() -> [String: Any] {
        return [
            "latitude": latitude,
            "longitude": longitude
        ]
    }
}
