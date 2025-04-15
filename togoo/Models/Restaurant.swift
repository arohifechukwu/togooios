//
//  Restaurant.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct Restaurant: Identifiable, Codable {
    var id: String
    var name: String
    var address: String
    var imageURL: String
    var email: String?
    var rating: Double
    var distanceKm: Double
    var etaMinutes: Int
    var location: LocationCoordinates?
    var restaurantLicense: String?
    var retailLicense: String?
    var operatingHours: [String: OperatingHours]?

    // MARK: - Identifiable
    var uuid: String { id }

    // MARK: - Default initializer
    init(id: String, name: String, address: String, imageURL: String,
         location: LocationCoordinates?, operatingHours: [String: OperatingHours]?,
         rating: Double, distanceKm: Double, etaMinutes: Int) {
        self.id = id
        self.name = name
        self.address = address
        self.imageURL = imageURL
        self.location = location
        self.operatingHours = operatingHours
        self.rating = rating
        self.distanceKm = distanceKm
        self.etaMinutes = etaMinutes
    }

    // MARK: - Firebase-style initializer
    init?(dict: [String: Any], id: String) {
        guard let name = dict["name"] as? String,
              let address = dict["address"] as? String,
              let imageURL = dict["imageURL"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
        self.address = address
        self.imageURL = imageURL
        self.email = dict["email"] as? String
        self.restaurantLicense = dict["restaurantLicense"] as? String
        self.retailLicense = dict["retailLicense"] as? String

        // Convert location if present
        if let locationDict = dict["location"] as? [String: Any] {
            self.location = LocationCoordinates(dict: locationDict)
        } else {
            self.location = nil
        }

        // Convert operatingHours if present
        if let opHours = dict["operatingHours"] as? [String: Any] {
            var parsedHours = [String: OperatingHours]()
            for (key, value) in opHours {
                if let hourDict = value as? [String: Any],
                   let hours = OperatingHours(dict: hourDict) {
                    parsedHours[key] = hours
                }
            }
            self.operatingHours = parsedHours
        }

        // Parse rating safely
        if let rawRating = dict["rating"] {
            if let rating = rawRating as? Double {
                self.rating = rating
            } else if let ratingString = rawRating as? String, let parsed = Double(ratingString) {
                self.rating = parsed
            } else {
                self.rating = 4.5 // Default fallback
            }
        } else {
            self.rating = 4.5
        }

        // Parse distance safely
        if let rawDistance = dict["distanceKm"] {
            if let dist = rawDistance as? Double {
                self.distanceKm = dist
            } else if let distString = rawDistance as? String, let parsed = Double(distString) {
                self.distanceKm = parsed
            } else {
                self.distanceKm = 0.0
            }
        } else {
            self.distanceKm = 0.0
        }

        self.etaMinutes = dict["etaMinutes"] as? Int ?? 0
    }

    // MARK: - Convenience methods

    var latitude: Double {
        location?.latitudeAsDouble ?? 0.0
    }

    var longitude: Double {
        location?.longitudeAsDouble ?? 0.0
    }
}
