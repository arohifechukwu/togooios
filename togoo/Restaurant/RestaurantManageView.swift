//
//  RestaurantManageView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

struct RestaurantManageView: View {
    @StateObject private var viewModel = RestaurantManageViewModel()
    @State private var navigateToEdit: Bool = false
    @State private var selectedEditItem: FoodItemEditable?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Manage Food Items")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)

                TextField("Search food by name, category, section...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Food items found: \(viewModel.filteredItems.count) result\(viewModel.filteredItems.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.darkGray)
                    .padding(.top, 4)

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 12) {
                        ForEach(viewModel.filteredItems) { item in
                            VStack(alignment: .leading, spacing: 6) {
                                HStack(alignment: .top) {
                                    AsyncImage(url: URL(string: item.imageURL)) { image in
                                        image.resizable().scaledToFill()
                                    } placeholder: {
                                        Color.gray.opacity(0.2)
                                    }
                                    .frame(width: 80, height: 80)
                                    .cornerRadius(8)

                                    VStack(alignment: .leading) {
                                        Text(item.foodId).bold()
                                        Text(item.description).font(.subheadline).foregroundColor(.gray)
                                        Text("Price: $\(item.price, specifier: "%.2f")").font(.subheadline)
                                        if let category = item.category {
                                            Text("Category: \(category)").font(.footnote).foregroundColor(.secondary)
                                        }
                                        Text("Section: \(item.section)").font(.footnote).foregroundColor(.secondary)
                                    }
                                }

                                HStack {
                                    Button("Edit") {
                                        selectedEditItem = item
                                        navigateToEdit = true
                                    }
                                    .buttonStyle(.bordered)

                                    Button("Delete") {
                                        viewModel.delete(item: item)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(.red)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                        }

                        if viewModel.filteredItems.isEmpty {
                            Text("No matching food items.")
                                .foregroundColor(.gray)
                                .padding(.top, 32)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding()
                }

                RestaurantBottomNavigationView(selectedTab: "manage") { _ in }

                NavigationLink(destination: destinationView(), isActive: $navigateToEdit) {
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if let item = selectedEditItem {
            EditFoodItemView(
                restaurantId: Auth.auth().currentUser?.uid ?? "",
                parentNode: item.parentNode,
                category: item.category,
                foodId: item.foodId
            )
        } else {
            EmptyView()
        }
    }
}
