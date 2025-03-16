//
//  UsersCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseFunctions

struct UsersCardView: View {
    @State private var user: User
    let primaryColor: Color
    
    init(user: User, primaryColor: Color) {
        self.user = user
        self.primaryColor = primaryColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(user.name)
                .font(.headline)
                .foregroundColor(.black)
            
            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(user.role)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // ✅ Display "null" when status is missing
                        Text("Status: \(user.status.isEmpty ? "null" : user.status)")
                .font(.subheadline)
                .italic()
                .foregroundColor(primaryColor)
            
            HStack {
                Spacer()
                // ✅ Suspend/Reactivate Button
                Button(action: {
                    toggleUserStatus()
                }) {
                    Text(user.status.lowercased() == "suspended" ? "Reactivate" : "Suspend")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(user.status.lowercased() == "suspended" ? primaryColor : Color(red: 1.0, green: 0.75, blue: 0.4))
                        .cornerRadius(6)
                }

                // ✅ Delete Button
                Button(action: {
                    deleteUser()
                }) {
                    Text("Delete")
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(primaryColor)
                        .cornerRadius(6)
                }
            }
            .padding(.top, 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(primaryColor, lineWidth: 1)
                )
        .shadow(radius: 2)
    }
    
    
    // MARK: - Toggle User Status
    private func toggleUserStatus() {
        let dbRef = Database.database().reference()
        let newStatus = user.status.lowercased() == "suspended" ? "active" : "suspended"
        
        dbRef.child(user.role.lowercased()).child(user.userId).child("status").setValue(newStatus) { error, _ in
            if error == nil {
                DispatchQueue.main.async {
                    user.status = newStatus
                }
            }
        }
    }
    
    // MARK: - Delete User (Realtime Database + Firebase Authentication)
    private func deleteUser() {
        guard let currentUser = Auth.auth().currentUser else {
            print("Error: No authenticated admin user")
            return
        }

        // Ensure the admin is not deleting their own account
        if currentUser.uid == user.userId {
            print("Admins cannot delete their own account!")
            return
        }

        let dbRef = Database.database().reference()

        // ✅ 1. Get authentication token before calling the Firebase function
        currentUser.getIDToken { token, error in
            guard let idToken = token, error == nil else {
                print("Error fetching ID token: \(error?.localizedDescription ?? "Unknown error")")
                return
            }

            let functions = Functions.functions()

            // ✅ 2. Call the Firebase Cloud Function to delete the user from Firebase Auth
            functions.httpsCallable("deleteUser").call(["userId": user.userId, "token": idToken]) { result, error in
                if let error = error {
                    print("Error deleting user from Firebase Auth: \(error.localizedDescription)")
                    return
                }

                // ✅ 3. Delete user from Realtime Database
                dbRef.child(user.role.lowercased()).child(user.userId).removeValue { dbError, _ in
                    if dbError == nil {
                        print("User successfully deleted from database")
                    } else {
                        print("Failed to delete user from database: \(dbError?.localizedDescription ?? "Unknown error")")
                    }
                }
            }
        }
    }
}
