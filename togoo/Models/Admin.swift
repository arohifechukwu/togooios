//
//  Admin.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct Admin: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var phone: String
    var address: String
    var role: String
    var status: String
    var imageURL: String

    // MARK: - Initializer
    init(id: String, name: String, email: String, phone: String, address: String,
         role: String, status: String, imageURL: String) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.role = role
        self.status = status
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
        self.imageURL = imageURL
    }

    // MARK: - Firebase Dictionary Export (Optional)
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "email": email,
            "phone": phone,
            "address": address,
            "role": role,
            "status": status,
            "imageURL": imageURL
        ]
    }
}