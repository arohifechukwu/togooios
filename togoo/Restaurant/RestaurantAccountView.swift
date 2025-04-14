//
//  RestaurantAccountView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI
import FirebaseAuth

struct RestaurantAccountView: View {
    @AppStorage("darkMode") private var isDarkMode = false
    @State private var navigateToDestination = false
    @State private var destinationView: AnyView? = nil
    @State private var showProfile = false
    

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Account Dashboard")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .font(.headline)
                    .foregroundColor(.white)
                    .background(Color.primaryVariant)

                ScrollView {
                    VStack(spacing: 12) {
                        accountCard(icon: "ic_profile", label: "Profile") {
                            showProfile = true
                        }
                        .sheet(isPresented: $showProfile) {
                            RestaurantProfileView(backDestination: $showProfile)
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
                                    .tint(.primaryVariant)
                            }
                            .padding()
                        }

                        accountCard(icon: "ic_logout", label: "Logout") {
                            logoutUser()
                        }
                    }
                    .padding()
                }

                Spacer()

                RestaurantBottomNavigationView(selectedTab: "account") { selected in
                    destinationView = selected
                    navigateToDestination = true
                }
            }
            .navigationBarBackButtonHidden(true)
            .background(Color.white.edgesIgnoringSafeArea(.all))
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
}

struct RestaurantAccountView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantAccountView()
    }
}
