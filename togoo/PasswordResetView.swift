//
//  PasswordResetView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//

import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    // MARK: - State Properties
    @State private var email: String = ""
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var navigateToLogin: Bool = false

    // MARK: - Color Palette (using Color(hex:) from Color+Hex.swift)
    let primaryColor = Color(hex: "F18D34")        // Dark Orange
    let primaryVariant = Color(hex: "E67E22")        // Slightly Darker Orange
    let secondaryColor = Color(hex: "FF9800")        // Lighter Orange
    let white = Color.white
    let lightGray = Color(hex: "F5F5F5")
    let darkGray = Color(hex: "757575")
    let black = Color.black
    let buttonDefault = Color(hex: "F18D34")
    let buttonPressed = Color(hex: "E67E22")
    let buttonDisabled = Color(hex: "FFB066")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 50)
                    
                    // Logo
                    Image("logo") // Ensure "logo" is added in Assets.xcassets
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    Spacer().frame(height: 16)
                    
                    // Slogan
                    Text("Bringing Your Cravings Home!")
                        .font(.system(size: 18))
                        .italic()
                        .foregroundColor(darkGray)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 100)
                    
                    // Password Reset Title
                    Text("Reset Your Password")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(black)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 20)
                    
                    // Password Reset Form
                    VStack(spacing: 16) {
                        // Email Field
                        TextField("Enter Your Registered Email", text: $email)
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(lightGray)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(primaryColor, lineWidth: 1)
                            )
                        
                        // Disclaimer
                        Text("A valid registered email address is required to reset your password.")
                            .font(.system(size: 14))
                            .foregroundColor(darkGray)
                            .multilineTextAlignment(.center)
                        
                        Spacer().frame(height: 40)
                        
                        // Reset Password Button
                        Button(action: {
                            resetPassword()
                        }) {
                            Text("Reset Password")
                                .font(.system(size: 16))
                                .foregroundColor(white)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(buttonDefault)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .background(white)
            .navigationBarBackButtonHidden(true) // Disable default back button
            .toolbar {
                // Custom back navigation button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // Navigate back to LoginView
                        navigateToLogin = true
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToLogin) {
                LoginView()
                    .navigationBarBackButtonHidden(true)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Password Reset"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Password Reset Functionality using Firebase
    func resetPassword() {
        guard !email.isEmpty else {
            alertMessage = "Please enter your email."
            showAlert = true
            return
        }
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                alertMessage = "Failed to send reset email. Check your email and try again. \(error.localizedDescription)"
                showAlert = true
            } else {
                alertMessage = "Password reset email sent!"
                showAlert = true
                // Optionally, navigate back to login after a short delay:
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    navigateToLogin = true
                }
            }
        }
    }
}

struct PasswordResetView_Previews: PreviewProvider {
    static var previews: some View {
        PasswordResetView()
    }
}
