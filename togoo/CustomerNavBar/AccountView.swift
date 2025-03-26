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

    let primaryColor = Color(hex: "F18D34")
    let backgroundColor = Color.white

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Title Bar
                Text("Account Dashboard")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(primaryColor)

                ScrollView {
                    VStack(spacing: 12) {
                        accountCard(icon: "ic_profile", label: "Profile") {
                            destinationView = AnyView(ProfileView())
                            navigateToDestination = true
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

                        // Theme Switch
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
                

                // Bottom Navigation
                bottomNavigationBar
            }
            .navigationBarBackButtonHidden(true)
            .background(backgroundColor.edgesIgnoringSafeArea(.all))
            .navigationDestination(isPresented: $navigateToDestination) {
                destinationView
            }
        }
    }

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

    private func logoutUser() {
        try? Auth.auth().signOut()
        destinationView = AnyView(LoginView())
        navigateToDestination = true
    }

    private var bottomNavigationBar: some View {
        HStack {
            CustomerBottomNavItem(imageName: "ic_home", title: "Home", isSelected: false) {
                destinationView = AnyView(CustomerHomeView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_restaurant", title: "Restaurants", isSelected: false) {
                destinationView = AnyView(RestaurantView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_browse", title: "Browse", isSelected: false) {
                destinationView = AnyView(BrowseView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_order", title: "Order", isSelected: false) {
                destinationView = AnyView(OrderView())
                navigateToDestination = true
            }
            Spacer()
            CustomerBottomNavItem(imageName: "ic_account", title: "Account", isSelected: true) {}
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(backgroundColor)
    }
}

struct MaterialCardView<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack {
            content
        }
        .padding()
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .gray.opacity(0.5), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 12)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        AccountView()
    }
}
