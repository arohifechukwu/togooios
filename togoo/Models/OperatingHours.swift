//
//  OperatingHours.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-10.
//


import Foundation

struct OperatingHours: Codable {
    var open: String
    var close: String

    // MARK: - Initializer
    init(open: String, close: String) {
        self.open = open
        self.close = close
    }

    // MARK: - Firebase-style Initializer
    init?(dict: [String: Any]) {
        guard let open = dict["open"] as? String,
              let close = dict["close"] as? String else {
            return nil
        }
        self.open = open
        self.close = close
    }

    // MARK: - Optional Dictionary Output (for writing to Firebase)
    func toDictionary() -> [String: Any] {
        return [
            "open": open,
            "close": close
        ]
    }
}