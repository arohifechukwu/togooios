//
//  DriverBottomNavItem.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//


import SwiftUI

struct DriverBottomNavItem: View {
    var selectedTab: String
    var onTabSelected: (AnyView) -> Void

    var body: some View {
        HStack(spacing: 0) {
            navItem(title: "Notifications", imageName: "ic_notification", isSelected: selectedTab == "notifications") {
                onTabSelected(AnyView(DriverNotificationsView()))
            }
            navItem(title: "Orders", imageName: "ic_buy", isSelected: selectedTab == "orders") {
                onTabSelected(AnyView(DriverHomeView()))
            }
            navItem(title: "Reports", imageName: "ic_report", isSelected: selectedTab == "reports") {
                onTabSelected(AnyView(DriverReportView()))
            }
            navItem(title: "Account", imageName: "ic_setting", isSelected: selectedTab == "account") {
                onTabSelected(AnyView(DriverAccountView()))
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
