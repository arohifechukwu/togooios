//
//  LocationManager.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import Foundation
import CoreLocation
import SwiftUI

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var locationName: String = "Unknown Location"
    @Published var location: CLLocation? = nil  // Current location
    
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // Request when-in-use authorization and log the current authorization status
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startUpdating() {
        // Only start updating if authorization is granted
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            print("Location permission not granted")
        }
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingLocation()
    }
    
    // Delegate method for authorization changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            print("Location access granted")
            startUpdating()
        case .denied, .restricted:
            print("Location access denied or restricted")
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        self.location = loc  // Update published location
        print("📍 Current simulated location: \(loc.coordinate.latitude), \(loc.coordinate.longitude)")
        fetchAddress(from: loc)
    }
    
    
    private func fetchAddress(from location: CLLocation) {
        let geocoder = CLGeocoder()
        print("🌍 Starting reverse geocoding for \(location.coordinate.latitude), \(location.coordinate.longitude)")
        
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let error = error {
                print("❌ Reverse geocoding error: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else {
                print("❌ No placemark found for location: \(location.coordinate)")
                return
            }
            
            var components: [String] = []
            
            if let locality = placemark.locality {
                components.append(locality)
            }
            if let administrativeArea = placemark.administrativeArea {
                components.append(administrativeArea)
            }
            if let country = placemark.country {
                components.append(country)
            }
            
            let name = components.joined(separator: ", ")
            DispatchQueue.main.async {
                self?.locationName = name.isEmpty ? "Unknown Location" : name
                print("✅ Location name updated to: \(self?.locationName ?? "nil")")
            }
        }
    }
    
}

