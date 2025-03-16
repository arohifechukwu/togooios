//
//  User.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


import Foundation

struct User: Identifiable {
    var id: String { userId }
    var userId: String
    var name: String
    var email: String
    var role: String
    var status: String
}
