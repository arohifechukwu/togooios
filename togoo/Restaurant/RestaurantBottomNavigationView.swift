//
//  RestaurantBottomNavigationView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct RestaurantBottomNavigationView: View {
    var selectedTab: String
    var onTabSelected: (AnyView) -> Void

    var body: some View {
        HStack(spacing: 0) {
            navItem(title: "Orders", imageName: "ic_order", isSelected: selectedTab == "orders") {
                onTabSelected(AnyView(RestaurantHomeView()))
            }
            navItem(title: "New", imageName: "ic_create", isSelected: selectedTab == "new") {
                onTabSelected(AnyView(RestaurantNewView()))
            }
            navItem(title: "Reports", imageName: "ic_report", isSelected: selectedTab == "reports") {
                onTabSelected(AnyView(RestaurantReportView()))
            }
            navItem(title: "Manage", imageName: "ic_manage", isSelected: selectedTab == "manage") {
                onTabSelected(AnyView(RestaurantManageView()))
            }
            navItem(title: "Account", imageName: "ic_account", isSelected: selectedTab == "account") {
                onTabSelected(AnyView(RestaurantAccountView()))
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -1)
    }

    @ViewBuilder
    func navItem(title: String, imageName: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
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
