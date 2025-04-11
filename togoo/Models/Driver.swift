//
//  Driver.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct Driver: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var address: String
    var role: String
    var status: String
    var driverLicense: String
    var vehicleRegistration: String
    var imageURL: String

    // MARK: - Initializer
    init(id: String, name: String, email: String, phone: String, address: String,
         role: String, status: String, driverLicense: String, vehicleRegistration: String, imageURL: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.role = role
        self.status = status
        self.driverLicense = driverLicense
        self.vehicleRegistration = vehicleRegistration
        self.imageURL = imageURL
    }

    // MARK: - Firebase-style Initializer
    init?(dict: [String: Any], id: String) {
        guard let name = dict["name"] as? String,
              let email = dict["email"] as? String,
              let phone = dict["phone"] as? String,
              let address = dict["address"] as? String,
              let role = dict["role"] as? String,
              let status = dict["status"] as? String,
              let driverLicense = dict["driverLicense"] as? String,
              let vehicleRegistration = dict["vehicleRegistration"] as? String,
              let imageURL = dict["imageURL"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.role = role
        self.status = status
        self.driverLicense = driverLicense
        self.vehicleRegistration = vehicleRegistration
        self.imageURL = imageURL
    }

    // MARK: - Dictionary Representation (optional)
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "phone": phone,
            "address": address,
            "role": role,
            "status": status,
            "driverLicense": driverLicense,
            "vehicleRegistration": vehicleRegistration,
            "imageURL": imageURL
        ]
    }
}