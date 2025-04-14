//
//  DriverAccountView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct DriverAccountView: View {
    @AppStorage("darkMode") private var isDarkMode = false
    @State private var isAvailable = false
    @State private var showProfile = false
    @State private var navigateTo: AnyView? = nil
    @State private var showNavigation = false

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
                            DriverProfileView(backToAccount: $showProfile)
                        }

                        accountCard(icon: "ic_notifications", label: "Notifications") {
                            navigateTo = AnyView(DriverNotificationsView())
                            showNavigation = true
                        }

                        availabilityToggleCard()

                        accountCard(icon: "ic_info", label: "About Us") {
                            navigateTo = AnyView(AboutUsView())
                            showNavigation = true
                        }

                        accountCard(icon: "ic_faq", label: "FAQ") {
                            navigateTo = AnyView(FAQView())
                            showNavigation = true
                        }

                        accountCard(icon: "ic_language", label: "Language") {
                            navigateTo = AnyView(LanguageView())
                            showNavigation = true
                        }

                        themeToggleCard()

                        accountCard(icon: "ic_logout", label: "Logout") {
                            logoutUser()
                        }
                    }
                    .padding()
                }

                DriverBottomNavItem(selectedTab: "account") { tab in
                    navigateTo = tab
                    showNavigation = true
                }
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $showNavigation) {
                if let view = navigateTo {
                    view
                }
            }
            .onAppear(perform: loadAvailability)
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

    private func availabilityToggleCard() -> some View {
        MaterialCardView {
            HStack {
                Image("ic_available")
                    .resizable()
                    .frame(width: 24, height: 24)

                Text("Availability")
                    .font(.body)
                    .foregroundColor(.black)
                    .padding(.leading)

                Spacer()

                Toggle("", isOn: $isAvailable)
                    .labelsHidden()
                    .tint(.primaryVariant)
                    .onChange(of: isAvailable) { newValue in
                        updateAvailability(to: newValue)
                    }
            }
            .padding()
        }
    }

    private func themeToggleCard() -> some View {
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
    }

    private func logoutUser() {
        try? Auth.auth().signOut()
        navigateTo = AnyView(LoginView())
        showNavigation = true
    }

    private func loadAvailability() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("driver").child(uid).child("availability")
        ref.observeSingleEvent(of: .value) { snapshot in
            if let status = snapshot.value as? String {
                isAvailable = status.lowercased() == "available"
            }
        }
    }

    private func updateAvailability(to newStatus: Bool) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child("driver").child(uid).child("availability")
        ref.setValue(newStatus ? "available" : "unavailable")
    }
}

#Preview {
    DriverAccountView()
}
