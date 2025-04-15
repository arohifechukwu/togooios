//
//  UsersView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct UsersView: View {
    @State private var users: [User] = []
    @State private var selectedTab: Tab = .users
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
                Text("Users List")
                    .font(.headline)
                    .foregroundColor(white)
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(primaryColor)
                
                // Card View for User List
                ZStack {
                    if users.isEmpty {
                        Text("No records found")
                            .font(.title3)
                            .foregroundColor(darkGray)
                    } else {
                        ScrollView {
                            VStack(spacing: 10) {
                                ForEach(users) { user in
                                    UsersCardView(user: user, primaryColor: primaryColor)
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
                    AdminBottomNavItem(imageName: "ic_users", title: Tab.users.rawValue, isSelected:
                                        selectedTab == .users) {
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
                fetchUsers()
            }
        }
    }
    
    
    func fetchUsers() {
        let dbRef = Database.database().reference()
        var allUsers: [User] = []
        let group = DispatchGroup()
        let nodes = ["customer", "driver", "restaurant", "admin"]
        
        for node in nodes {
            group.enter()
            dbRef.child(node).observeSingleEvent(of: .value, with: { snapshot in
                for case let child as DataSnapshot in snapshot.children {
                    if let userData = child.value as? [String: Any] {
                        let user = User(
                            userId: child.key,
                            name: userData["name"] as? String ?? "",
                            email: userData["email"] as? String ?? "",
                            phone: userData["phone"] as? String ?? "",
                            address: userData["address"] as? String ?? "",
                            role: node.capitalized,
                            status: userData["status"] as? String ?? "",
                            imageURL: userData["imageURL"] as? String ?? ""
                        )
                        allUsers.append(user)
                    }
                }
                group.leave()
            }, withCancel: { error in
                print("❌ Error fetching users from \(node): \(error.localizedDescription)")
                group.leave()
            })
        }
        
        group.notify(queue: .main) {
            self.users = allUsers
        }
    }
    
    
    // MARK: - Preview
    struct UsersView_Previews: PreviewProvider {
        static var previews: some View {
            UsersView()
        }
    }
}
