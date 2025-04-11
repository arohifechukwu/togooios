//
//  Customer.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct Customer: Identifiable, Codable {
    var id: String
    var name: String
    var phone: String
    var address: String

    // MARK: - Initializer
    init(id: String, name: String, phone: String, address: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.address = address
    }

    // MARK: - Firebase-style Initializer
    init?(dict: [String: Any], id: String) {
        guard let name = dict["name"] as? String,
              let phone = dict["phone"] as? String,
              let address = dict["address"] as? String else {
            return nil
        }

        self.id = id
        self.name = name
        self.phone = phone
        self.address = address
    }

    // MARK: - Dictionary Representation (optional for Firebase)
    func toDictionary() -> [String: Any] {
        return [
            "name": name,
            "phone": phone,
            "address": address
        ]
    }
}