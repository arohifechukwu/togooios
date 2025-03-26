//
//  SignupView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//

import SwiftUI
import FirebaseAuth
import FirebaseDatabase

// Custom Checkbox Toggle Style for iOS
struct CheckboxToggleStyle: ToggleStyle {
    var tint: Color = .accentColor
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundColor(configuration.isOn ? tint : .secondary)
                configuration.label
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SignupView: View {
    @Environment(\.presentationMode) private var presentationMode

    // MARK: - State Properties for Form Inputs
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var termsAccepted: Bool = false
    @State private var passwordVisible: Bool = false
    @State private var confirmPasswordVisible: Bool = false
    
    // MARK: - State for Alerts & Navigation
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
    let buttonDefault = Color(hex: "F18D34")
    let buttonPressed = Color(hex: "E67E22")
    let buttonDisabled = Color(hex: "FFB066")
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 60)
                    
                    // Logo
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    
                    // Slogan
                    Text("Bringing Your Cravings Home!")
                        .font(.system(size: 18))
                        .italic()
                        .foregroundColor(darkGray)
                        .multilineTextAlignment(.center)
                    
                    Spacer().frame(height: 30)
                    
                    // Signup Form Fields
                    Group {
                        customTextField(text: $fullName, placeholder: "Full Name", keyboardType: .namePhonePad)
                        customTextField(text: $email, placeholder: "Email", keyboardType: .emailAddress)
                        customTextField(text: $phone, placeholder: "Phone", keyboardType: .phonePad)
                        customTextField(text: $address, placeholder: "Address", keyboardType: .default)
                    }
                    .padding(.horizontal, 24)
                    
                    // Password Fields with Toggle
                    Group {
                        customPasswordField(text: $password, placeholder: "Password", isVisible: $passwordVisible)
                        customPasswordField(text: $confirmPassword, placeholder: "Confirm Password", isVisible: $confirmPasswordVisible)
                    }
                    .padding(.horizontal, 24)
                    
                    // Password Hint
                    Text("Password must be at least 6 characters and contain letters, numbers, and symbols (e.g., P@ssw0rd!)")
                        .font(.system(size: 14))
                        .foregroundColor(darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Terms & Conditions Checkbox using custom style
                    Toggle(isOn: $termsAccepted) {
                        Text("I agree to Terms & Conditions")
                            .foregroundColor(darkGray)
                    }
                    .toggleStyle(CheckboxToggleStyle(tint: primaryColor))
                    .padding(.horizontal, 24)
                    
                    // Signup Button
                    Button(action: {
                        registerUser()
                    }) {
                        Text("Signup")
                            .font(.system(size: 16))
                            .foregroundColor(white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(buttonDefault)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    
                    // Navigation Links
                    VStack(spacing: 10) {
                        Button(action: {
                            navigateToLogin = true
                        }) {
                            Text("Already registered? Log In")
                                .foregroundColor(primaryColor)
                                .fontWeight(.bold)
                        }
                        NavigationLink(destination: RegistrationView()) {
                                                Text("Are You A Driver Or Own A Restaurant? Register Here!")
                                                    .foregroundColor(secondaryColor)
                                                    .fontWeight(.bold)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .background(white)
            .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {
                // Custom back navigation button
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
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
            .alert("Signup Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    // MARK: - Helper View Builders
    func customTextField(text: Binding<String>, placeholder: String, keyboardType: UIKeyboardType) -> some View {
        TextField(placeholder, text: text)
            .keyboardType(keyboardType)
            .padding()
            .background(lightGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(darkGray, lineWidth: 1)
            )
            .padding(.bottom, 10)
    }
    
    func customPasswordField(text: Binding<String>, placeholder: String, isVisible: Binding<Bool>) -> some View {
        ZStack(alignment: .trailing) {
            Group {
                if isVisible.wrappedValue {
                    TextField(placeholder, text: text)
                } else {
                    SecureField(placeholder, text: text)
                }
            }
            .padding()
            .background(lightGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(darkGray, lineWidth: 1)
            )
            .padding(.bottom, 10)
            
            Button(action: {
                isVisible.wrappedValue.toggle()
            }) {
                Image(systemName: isVisible.wrappedValue ? "eye" : "eye.slash")
                    .foregroundColor(primaryColor)
                    .padding(.trailing, 10)
            }
        }
    }
    
    // MARK: - Firebase Signup Functionality (store in Realtime DB under "customer")
    func registerUser() {
        guard !fullName.isEmpty,
              !email.isEmpty,
              !phone.isEmpty,
              !address.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        guard termsAccepted else {
            alertMessage = "You must accept the Terms & Conditions."
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match!"
            showAlert = true
            return
        }
        guard isValidPassword(password) else {
            alertMessage = "Password must be at least 6 characters and include letters, numbers, and symbols."
            showAlert = true
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error {
                alertMessage = "Signup failed: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            let userRef = Database.database().reference().child("customer").child(uid)
            
            // Prepare user data
            let userData: [String: Any] = [
                "name": fullName,
                "email": email,
                "phone": phone,
                "address": address,
                "role": "customer",
                "createdAt": ServerValue.timestamp()
            ]
            
            userRef.setValue(userData) { error, _ in
                if let error = error {
                    alertMessage = "Error saving user data: \(error.localizedDescription)"
                    showAlert = true
                } else {
                    navigateToLogin = true
                }
            }
        }
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@#$%^&+=!]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}

struct SignupView_Previews: PreviewProvider {
    static var previews: some View {
        SignupView()
    }
}
