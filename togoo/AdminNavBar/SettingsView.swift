//
//  SettingsView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedTab: Tab = .settings
    @State private var navigateToDestination: Bool = false
    @State private var destinationView: AnyView? = nil

    // Define tabs for bottom navigation
    enum Tab: String {
        case dashboard = "Dashboard"
        case users = "Users"
        case approvals = "Approvals"
        case transaction = "Transaction"
        case settings = "Settings"
    }

    // MARK: - Color Palette
    let primaryColor = Color(hex: "F18D34") // Dark Orange
    let primaryVariant = Color(hex: "E67E22") // Slightly Darker Orange
    let secondaryColor = Color(hex: "FF9800") // Lighter Orange
    let lightGray = Color(hex: "F5F5F5")
    let darkGray = Color(hex: "757575")
    let white = Color.white
    let black = Color.black

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Settings")
                    .font(.headline)
                    .foregroundColor(white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(primaryColor)

                // Settings List
                ScrollView {
                    VStack(spacing: 10) {
                        SettingCard(imageName: "ic_profile", title: "Profile") {
                            destinationView = AnyView(ProfileView())
                            navigateToDestination = true
                        }
                        SettingCard(imageName: "ic_notifications", title: "Notifications") {
                            destinationView = AnyView(NotificationsView())
                            navigateToDestination = true
                        }
                        SettingCard(imageName: "ic_info", title: "About Us") {
                            destinationView = AnyView(AboutUsView())
                            navigateToDestination = true
                        }
                        SettingCard(imageName: "ic_faq", title: "FAQ") {
                            destinationView = AnyView(FAQView())
                            navigateToDestination = true
                        }
                        SettingCard(imageName: "ic_language", title: "Language") {
                            destinationView = AnyView(LanguageView())
                            navigateToDestination = true
                        }

                        // Dark Mode Toggle
                        darkModeToggle

                        // Logout Button
                        logoutButton
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                }

                // Bottom Navigation Bar
                bottomNavBar
            }
            .background(lightGray.edgesIgnoringSafeArea(.all))
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToDestination) {
                if let destination = destinationView {
                    destination.navigationBarBackButtonHidden(true)
                } else {
                    EmptyView()
                }
            }
        }
    }

    // MARK: - Dark Mode Toggle
    private var darkModeToggle: some View {
        HStack {
            Image("ic_dark_mode")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)

            Text("Dark Mode")
                .font(.subheadline)
                .foregroundColor(black)
                .padding(.leading, 10)

            Spacer()

            Toggle("", isOn: $isDarkMode)
                .labelsHidden()
                .toggleStyle(SwitchToggleStyle(tint: primaryColor))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(white)
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal, 8)
    }

    // MARK: - Logout Button
    private var logoutButton: some View {
        Button(action: logoutUser) {
            HStack {
                Image("ic_logout")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text("Logout")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.leading, 10)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 8)
    }

    // MARK: - Logout Function
    private func logoutUser() {
        do {
            try Auth.auth().signOut()
            navigateToDestination = true
            destinationView = AnyView(LoginView())
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }

    // MARK: - Bottom Navigation Bar
    private var bottomNavBar: some View {
        HStack {
            Spacer()
            AdminBottomNavItem(imageName: "ic_dashboard", title: Tab.dashboard.rawValue, isSelected: selectedTab == .dashboard) {
                selectedTab = .dashboard
                destinationView = AnyView(AdminHomeView())
                navigateToDestination = true
            }
            Spacer()
            AdminBottomNavItem(imageName: "ic_users", title: Tab.users.rawValue, isSelected: selectedTab == .users) {
                selectedTab = .users
                destinationView = AnyView(UsersView())
                navigateToDestination = true
            }
            Spacer()
            AdminBottomNavItem(imageName: "ic_approvals", title: Tab.approvals.rawValue, isSelected: selectedTab == .approvals) {
                selectedTab = .approvals
                destinationView = AnyView(ApprovalView())
                navigateToDestination = true
            }
            Spacer()
            AdminBottomNavItem(imageName: "ic_transaction", title: Tab.transaction.rawValue, isSelected: selectedTab == .transaction) {
                selectedTab = .transaction
                destinationView = AnyView(TransactionView())
                navigateToDestination = true
            }
            Spacer()
            AdminBottomNavItem(imageName: "ic_settings", title: Tab.settings.rawValue, isSelected: selectedTab == .settings) {
                selectedTab = .settings
            }
            Spacer()
        }
        .padding()
        .background(white)
        .shadow(radius: 4)
    }
}

// MARK: - SettingCard
struct SettingCard: View {
    let imageName: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)

                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(.leading, 10)

                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 2)
        }
        .padding(.horizontal, 8)
    }
}

// MARK: - Preview
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
