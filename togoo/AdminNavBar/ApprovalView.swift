//
//  ApprovalView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct ApprovalView: View {
    @State private var pendingUsers: [User] = []
    @State private var selectedTab: Tab = .approvals
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
                Text("Pending Approvals")
                    .font(.headline)
                    .foregroundColor(white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(primaryColor)

                // Pending Approvals List
                ZStack {
                    if pendingUsers.isEmpty {
                        Text("No pending approvals.")
                            .font(.title3)
                            .foregroundColor(darkGray)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(pendingUsers) { user in
                                    ApprovalCardView(
                                        pendingUsers: $pendingUsers,
                                        user: user,
                                        primaryColor: primaryColor
                                    )
                                    .padding(.horizontal, 8)
                                }
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(white)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(primaryColor, lineWidth: 1)
                )
                .padding(.horizontal, 8)
                .padding(.vertical, 8)
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)

                // Bottom Navigation Bar
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
                        destinationView = AnyView(SettingsView())
                        navigateToDestination = true
                    }
                    Spacer()
                }
                .padding()
                .background(white)
                .shadow(radius: 4)
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
            .onAppear {
                fetchPendingApprovals()
            }
        }
    }

    // MARK: - Fetch Pending Approvals from Realtime Database
    func fetchPendingApprovals() {
        let dbRef = Database.database().reference()
        var allPendingUsers: [User] = []
        let group = DispatchGroup()
        let nodes = ["driver", "restaurant"]

        for node in nodes {
            group.enter()
            dbRef.child(node).observeSingleEvent(of: .value) { snapshot in
                for case let child as DataSnapshot in snapshot.children {
                    if let userData = child.value as? [String: Any],
                       let status = userData["status"] as? String,
                       status.lowercased() == "pending" {
                        
                        // Construct user with fallback values for optional fields
                        let user = User(
                            userId: child.key,
                            name: userData["name"] as? String ?? "",
                            email: userData["email"] as? String ?? "",
                            phone: userData["phone"] as? String ?? "",
                            address: userData["address"] as? String ?? "",
                            role: userData["role"] as? String ?? node, // fallback to node name
                            status: status,
                            imageURL: userData["imageURL"] as? String ?? ""
                        )

                        allPendingUsers.append(user)
                    }
                }
                group.leave()
            } withCancel: { error in
                print("❌ Error fetching \(node): \(error.localizedDescription)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.pendingUsers = allPendingUsers
        }
    }
}

// MARK: - Preview
struct ApprovalView_Previews: PreviewProvider {
    static var previews: some View {
        ApprovalView()
    }
}
