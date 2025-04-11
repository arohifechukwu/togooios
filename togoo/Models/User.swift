//
//  User.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


//import Foundation
//
//struct User: Identifiable {
//    var id: String { userId }
//    var userId: String
//    var name: String
//    var email: String
//    var role: String
//    var status: String
//}



import Foundation

struct User: Identifiable, Codable {
    var id: String { userId }

    var userId: String
    var name: String
    var email: String
    var phone: String
    var address: String
    var role: String
    var status: String   // "Pending" or "Approved"
    var imageURL: String // Profile picture URL

    // MARK: - Initializer

    init(userId: String, name: String, email: String, phone: String, address: String, role: String, status: String, imageURL: String) {
        self.userId = userId
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.role = role
        self.status = status
        self.imageURL = imageURL
    }

    // MARK: - Firebase-style Initializer

    init?(dict: [String: Any]) {
        guard let userId = dict["userId"] as? String,
              let name = dict["name"] as? String,
              let email = dict["email"] as? String,
              let phone = dict["phone"] as? String,
              let address = dict["address"] as? String,
              let role = dict["role"] as? String,
              let status = dict["status"] as? String,
              let imageURL = dict["imageURL"] as? String else {
            return nil
        }

        self.userId = userId
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.role = role
        self.status = status
        self.imageURL = imageURL
    }

    // MARK: - Dictionary Representation (for Firebase)

    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
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
