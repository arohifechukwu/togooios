//
//  ApprovalCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


import SwiftUI
import FirebaseDatabase

struct ApprovalCardView: View {
    @Binding var pendingUsers: [User]
    let user: User
    let primaryColor: Color

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

            Text("Status: \(user.status.isEmpty ? "null" : user.status)")
                .font(.subheadline)
                .italic()
                .foregroundColor(primaryColor)

            HStack {
                Spacer()

                // ✅ Approve Button
                Button(action: {
                    approveUser()
                }) {
                    Text("Approve")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(primaryColor)
                        .cornerRadius(6)
                }

                // ✅ Decline Button
                Button(action: {
                    declineUser()
                }) {
                    Text("Decline")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 6)
                        .background(Color(red: 1.0, green: 0.75, blue: 0.4))
                        .cornerRadius(6)
                }
            }
            .padding(.top, 6)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(primaryColor, lineWidth: 1)
        )
        .shadow(radius: 2)
    }

    
    // MARK: - Approve User
    private func approveUser() {
        let dbRef = Database.database().reference()
        
        dbRef.child(user.role.lowercased()).child(user.userId).child("status").setValue("approved") { error, _ in
            if error == nil {
                DispatchQueue.main.async {
                    print("User approved successfully")

                    // ✅ Remove the approved user from the list
                    if let index = pendingUsers.firstIndex(where: { $0.userId == user.userId }) {
                        pendingUsers.remove(at: index)
                    }
                }
            } else {
                print("Error approving user: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }

    // MARK: - Decline User
    private func declineUser() {
        let dbRef = Database.database().reference()
        dbRef.child(user.role.lowercased()).child(user.userId).removeValue { error, _ in
            if error == nil {
                print("User declined and removed successfully")
            }
        }
    }
}

// MARK: - Preview
struct ApprovalCardView_Previews: PreviewProvider {
    static var previews: some View {
        ApprovalCardView(pendingUsers: .constant([
            User(userId: "2", name: "Mark Smith", email: "mark@example.com", role: "Driver", status: "Pending")
        ]), user: User(userId: "2", name: "Mark Smith", email: "mark@example.com", role: "Driver", status: "Pending"), primaryColor: Color(hex: "F18D34"))
    }
}
