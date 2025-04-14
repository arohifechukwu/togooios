//
//  AccountView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-25.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct AccountView: View {
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage("darkMode") private var isDarkMode = false

    @State private var navigateToDestination = false
    @State private var destinationView: AnyView? = nil
    @State private var showProfileSheet = false
    @State private var selectedTab: String = "account"

    let primaryColor = Color(hex: "F18D34")
    let backgroundColor = Color.white
    let darkGray = Color(hex: "757575")

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                Text("Account Dashboard")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(primaryColor)

                ScrollView {
                    VStack(spacing: 12) {
                        accountCard(icon: "ic_profile", label: "Profile") {
                            showProfileSheet = true
                        }

                        accountCard(icon: "ic_notifications", label: "Notifications") {
                            destinationView = AnyView(NotificationsView())
                            navigateToDestination = true
                        }

                        accountCard(icon: "ic_info", label: "About Us") {
                            destinationView = AnyView(AboutUsView())
                            navigateToDestination = true
                        }

                        accountCard(icon: "ic_faq", label: "FAQ") {
                            destinationView = AnyView(FAQView())
                            navigateToDestination = true
                        }

                        accountCard(icon: "ic_language", label: "Language") {
                            destinationView = AnyView(LanguageView())
                            navigateToDestination = true
                        }

                        // Dark Mode toggle
                        MaterialCardView {
                            HStack {
                                Image("ic_dark_mode")
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                Text("Dark Mode")
                                    .font(.body)
                                    .foregroundColor(.black)
                                    .padding(.leading)

                                Spacer()

                                Toggle("", isOn: $isDarkMode)
                                    .labelsHidden()
                                    .tint(primaryColor)
                            }
                            .padding()
                        }

                        // Logout
                        accountCard(icon: "ic_logout", label: "Logout") {
                            logoutUser()
                        }
                    }
                    .padding()
                }

                Spacer()

                // Bottom Nav Bar
                bottomNavigationBar
            }
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToDestination) {
                destinationView
            }
            .sheet(isPresented: $showProfileSheet) {
                ProfileView()
            }
        }
    }

    // MARK: - Reusable Material Card
    private func accountCard(icon: String, label: String, action: @escaping () -> Void) -> some View {
        MaterialCardView {
            Button(action: action) {
                HStack {
                    Image(icon)
                        .resizable()
                        .frame(width: 24, height: 24)

                    Text(label)
                        .font(.body)
                        .foregroundColor(.black)
                        .padding(.leading)

                    Spacer()
                }
                .padding()
            }
        }
    }

    // MARK: - Bottom Navigation Bar
    private var bottomNavigationBar: some View {
        HStack(spacing: 0) {
            navItem(title: "Home", imageName: "ic_home", tab: "home") {
                destinationView = AnyView(CustomerHomeView())
                selectedTab = "home"
                navigateToDestination = true
            }
            navItem(title: "Restaurants", imageName: "ic_restaurant", tab: "restaurants") {
                destinationView = AnyView(RestaurantView())
                selectedTab = "restaurants"
                navigateToDestination = true
            }
            navItem(title: "Orders", imageName: "ic_order", tab: "orders") {
                destinationView = AnyView(OrderView())
                selectedTab = "orders"
                navigateToDestination = true
            }
            navItem(title: "Account", imageName: "ic_account", tab: "account", isSelected: true) {
                // already on this page
            }
        }
        .padding(.vertical, 10)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: -1)
    }

    private func navItem(title: String, imageName: String, tab: String, isSelected: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
                    .foregroundColor(isSelected ? primaryColor : darkGray)

                Text(title)
                    .font(.caption2)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundColor(isSelected ? primaryColor : darkGray)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private func logoutUser() {
        try? Auth.auth().signOut()
        destinationView = AnyView(LoginView())
        navigateToDestination = true
    }
}


// MARK: - Preview
struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
