//
//  CustomerBottomNavItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//


import SwiftUI

struct CustomerBottomNavItem: View {
    var selectedTab: String
    var onTabSelected: (AnyView) -> Void

    var body: some View {
        HStack(spacing: 0) {
            navItem(title: "Home", imageName: "ic_home", isSelected: selectedTab == "home") {
                onTabSelected(AnyView(CustomerHomeView()))
            }
            navItem(title: "Restaurants", imageName: "ic_restaurant", isSelected: selectedTab == "restaurants") {
                onTabSelected(AnyView(RestaurantView()))
            }
            navItem(title: "Orders", imageName: "ic_order", isSelected: selectedTab == "orders") {
                onTabSelected(AnyView(OrderView()))
            }
            navItem(title: "Account", imageName: "ic_account", isSelected: selectedTab == "account") {
                onTabSelected(AnyView(AccountView()))
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -1)
    }

    @ViewBuilder
    private func navItem(title: String, imageName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? .primaryVariant : .darkGray)

                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? .primaryVariant : .darkGray)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
