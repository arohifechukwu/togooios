//
//  RestaurantManageViewModel.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//



import Foundation
import FirebaseDatabase
import FirebaseAuth

struct FoodItemEditable: Identifiable {
    let id = UUID()
    let foodId: String
    let description: String
    let price: Double
    let imageURL: String
    let section: String
    let category: String?
    let parentNode: String
}

class RestaurantManageViewModel: ObservableObject {
    @Published var allItems: [FoodItemEditable] = []
    @Published var filteredItems: [FoodItemEditable] = []
    @Published var searchQuery: String = "" {
        didSet { filterItems() }
    }

    private let db = Database.database().reference()

    init() {
        fetchSection("Special Offers")
        fetchSection("Top Picks")
        fetchMenu()
    }

    private func fetchSection(_ section: String) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.child("restaurant").child(uid).child(section).observe(.value) { snapshot in
            self.allItems.removeAll { $0.section == section }
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let dict = snap.value as? [String: Any],
                   let desc = dict["description"] as? String,
                   let price = dict["price"] as? Double,
                   let imgURL = dict["imageURL"] as? String,
                   let id = dict["id"] as? String {
                    let item = FoodItemEditable(
                        foodId: id,
                        description: desc,
                        price: price,
                        imageURL: imgURL,
                        section: section,
                        category: nil,
                        parentNode: section
                    )
                    self.allItems.append(item)
                }
            }
            self.filterItems()
        }
    }

    private func fetchMenu() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.child("restaurant").child(uid).child("menu").observe(.value) { snapshot in
            self.allItems.removeAll { $0.section == "menu" }
            for categorySnap in snapshot.children {
                guard let catSnap = categorySnap as? DataSnapshot else { continue }
                for itemSnap in catSnap.children {
                    if let snap = itemSnap as? DataSnapshot,
                       let dict = snap.value as? [String: Any],
                       let desc = dict["description"] as? String,
                       let price = dict["price"] as? Double,
                       let imgURL = dict["imageURL"] as? String,
                       let id = dict["id"] as? String {
                        let item = FoodItemEditable(
                            foodId: id,
                            description: desc,
                            price: price,
                            imageURL: imgURL,
                            section: "menu",
                            category: catSnap.key,
                            parentNode: "menu"
                        )
                        self.allItems.append(item)
                    }
                }
            }
            self.filterItems()
        }
    }

    func filterItems() {
        let query = searchQuery.lowercased()
        if query.isEmpty {
            filteredItems = allItems
        } else {
            filteredItems = allItems.filter {
                $0.foodId.lowercased().contains(query)
                || $0.section.lowercased().contains(query)
                || ($0.category?.lowercased().contains(query) ?? false)
            }.sorted(by: { a, b in
                let aStarts = a.foodId.lowercased().hasPrefix(query)
                let bStarts = b.foodId.lowercased().hasPrefix(query)
                return aStarts && !bStarts
            })
        }
    }

    func delete(item: FoodItemEditable) {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        let ref: DatabaseReference
        if item.parentNode == "menu" {
            guard let category = item.category else { return }
            ref = db.child("restaurant").child(uid).child("menu").child(category).child(item.foodId)
        } else {
            ref = db.child("restaurant").child(uid).child(item.parentNode).child(item.foodId)
        }

        ref.removeValue()
        allItems.removeAll { $0.foodId == item.foodId && $0.parentNode == item.parentNode }
        filterItems()
    }
}
