//
//  AppLocationManager.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import CoreLocation

class AppLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var locationName: String = "Fetching location..."

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func startUpdating() {
        locationManager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    func fetchUserLocation(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        if let loc = locationManager.location?.coordinate {
            completion(loc)
        } else {
            locationManager.requestLocation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                completion(self.locationManager.location?.coordinate)
            }
        }
    }

    /// ✅ Add this static utility method
    static func calculateDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let loc1 = CLLocation(latitude: lat1, longitude: lon1)
        let loc2 = CLLocation(latitude: lat2, longitude: lon2)
        let distanceInMeters = loc1.distance(from: loc2)
        return distanceInMeters / 1000.0 // convert to kilometers
    }
}