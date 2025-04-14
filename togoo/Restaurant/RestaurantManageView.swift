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
    @State private var navigate = false
    @State private var navigateTo: AnyView? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Manage Food Items")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.primaryVariant)

                TextField("Search food by name, category, section...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Text("Food items found: \(viewModel.filteredItems.count) result\(viewModel.filteredItems.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundColor(.darkGray)
                    .padding(.top, 4)

                let groupedItems = Dictionary(grouping: viewModel.filteredItems) {
                    $0.parentNode == "menu" ? "Menu - \($0.category ?? "")" : $0.parentNode
                }

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(groupedItems.keys).sorted(), id: \.self) { section in
                            if let items = groupedItems[section] {
                                Text(section)
                                    .font(.headline)
                                    .padding(.horizontal)

                                ForEach(items) { item in
                                    VStack(spacing: 0) {
                                        AsyncImage(url: URL(string: item.imageURL)) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image("ic_manage_food")
                                                .resizable()
                                                .scaledToFit()
                                                .opacity(0.3)
                                        }
                                        .frame(height: 160)
                                        .frame(maxWidth: .infinity)
                                        .clipped()
                                        .cornerRadius(12, corners: [.topLeft, .topRight])

                                        VStack(alignment: .leading, spacing: 6) {
                                            Text(item.foodId)
                                                .font(.headline)

                                            Text(item.description)
                                                .font(.subheadline)
                                                .foregroundColor(.gray)

                                            Text("Price: $\(item.price, specifier: "%.2f")")
                                                .font(.subheadline)

                                            HStack {
                                                Spacer()
                                                Button("Edit") {
                                                    selectedEditItem = item
                                                    navigateToEdit = true
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.primaryVariant)

                                                Button("Delete") {
                                                    viewModel.delete(item: item)
                                                }
                                                .buttonStyle(.borderedProminent)
                                                .tint(.primaryVariant)
                                            }
                                        }
                                        .padding()
                                    }
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                                    .padding(.horizontal)
                                }
                            }
                        }

                        if viewModel.filteredItems.isEmpty {
                            Text("No matching food items.")
                                .foregroundColor(.gray)
                                .padding(.top, 32)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.top)
                }

                RestaurantBottomNavigationView(selectedTab: "manage") { view in
                    navigateTo = view
                    navigate = true
                }

                NavigationLink(destination: destinationView(), isActive: $navigateToEdit) {
                    EmptyView()
                }
                NavigationLink(destination: navigateTo, isActive: $navigate) {
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden(true)
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

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}


struct RestaurantManageView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantManageView()
    }
}
