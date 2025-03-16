//
//  RegistrationStatusView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

struct RegistrationStatusView: View {
    // MARK: - State Variables
    @State private var statusText: String = "Checking registration status..."
    @State private var navigateToLanding: Bool = false
    @State private var destinationView: AnyView? = nil
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    
    // MARK: - Color Palette (using Color(hex:) from Color+Hex.swift)
    let primaryColor = Color(hex: "F18D34")   // Dark Orange
    let darkGray = Color(hex: "757575")
    let white = Color.white
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text(statusText)
                    .font(.system(size: 18))
                    .foregroundColor(darkGray)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button(action: {
                    logout()
                }) {
                    Text("Logout")
                        .font(.system(size: 16))
                        .foregroundColor(white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(primaryColor)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(white)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Custom back navigation button (if needed)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Dismiss or navigate back
                        // Use dismiss() if this view was presented modally
                        // Otherwise, set a navigation flag to navigate to LoginView.
                        // Here, we simply navigate to LoginView.
                        destinationView = AnyView(LoginView())
                        navigateToLanding = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToLanding) {
                if let destination = destinationView {
                    destination.navigationBarBackButtonHidden(true)
                } else {
                    EmptyView()
                }
            }
            .onAppear {
                checkRegistrationStatus()
            }
            .alert("Error", isPresented: $showError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Check Registration Status
    func checkRegistrationStatus() {
        guard let uid = Auth.auth().currentUser?.uid else {
            self.statusText = "User not logged in."
            return
        }
        
        let dbRef = Database.database().reference()
        // First, check the "driver" node
        dbRef.child("driver").child(uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let status = snapshot.childSnapshot(forPath: "status").value as? String {
                handleStatus(status: status, role: "driver")
            } else {
                // If not found in "driver", check "restaurant"
                dbRef.child("restaurant").child(uid).observeSingleEvent(of: .value) { snapshot in
                    if snapshot.exists(), let status = snapshot.childSnapshot(forPath: "status").value as? String {
                        handleStatus(status: status, role: "restaurant")
                    } else {
                        self.statusText = "Error: Registration not found."
                    }
                } withCancel: { error in
                    self.errorMessage = "Error fetching data: \(error.localizedDescription)"
                    self.showError = true
                }
            }
        } withCancel: { error in
            self.errorMessage = "Error fetching data: \(error.localizedDescription)"
            self.showError = true
        }
    }
    
    func handleStatus(status: String, role: String) {
        if status.lowercased() == "approved" {
            DispatchQueue.main.async {
                if role == "driver" {
                    destinationView = AnyView(DriverHomeView())
                } else {
                    destinationView = AnyView(RestaurantHomeView())
                }
                navigateToLanding = true
            }
        } else {
            DispatchQueue.main.async {
                self.statusText = "Registration awaiting approval, please check back later."
            }
        }
    }
    
    // MARK: - Logout Functionality
    func logout() {
        do {
            try Auth.auth().signOut()
            destinationView = AnyView(LoginView())
            navigateToLanding = true
        } catch {
            self.errorMessage = "Logout failed: \(error.localizedDescription)"
            self.showError = true
        }
    }
}

struct RegistrationStatusView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationStatusView()
    }
}
