//
//  LoginView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    // MARK: - State Properties
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var passwordVisible: Bool = false
    @State private var showError: Bool = false
    @State private var errorMessage: String = ""
    @State private var navigateToHome: Bool = false
    @State private var destinationView: AnyView? = nil
    @State private var isLoading: Bool = false

    // MARK: - Color Palette
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

    // MARK: - Body
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer().frame(height: 40)

                // Logo
                Image("logo") // Ensure "logo" is added in Assets.xcassets
                    .resizable()
                    .frame(width: 150, height: 150)
                
                Spacer().frame(height: 20)
                
                // Slogan
                Text("Bringing Your Cravings Home!")
                    .font(.system(size: 18))
                    .italic()
                    .foregroundColor(darkGray)
                
                Spacer().frame(height: 100)
                
                // Customer Login Image (tap does nothing here)
                Button(action: {
                    // Placeholder for action if needed
                }) {
                    Image("customer_login")
                        .resizable()
                        .frame(width: 50.0, height: 50)
                }
                
                // Form Fields
                VStack(spacing: 16) {
                    // Email Field
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(lightGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(darkGray, lineWidth: 1)
                        )
                    
                    // Password Field with Visibility Toggle
                    ZStack(alignment: .trailing) {
                        Group {
                            if passwordVisible {
                                TextField("Password", text: $password)
                            } else {
                                SecureField("Password", text: $password)
                            }
                        }
                        .padding()
                        .background(lightGray)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(darkGray, lineWidth: 1)
                        )
                        
                        Button(action: {
                            passwordVisible.toggle()
                        }) {
                            Image(systemName: passwordVisible ? "eye" : "eye.slash")
                                .foregroundColor(darkGray)
                                .padding(.trailing, 10)
                        }
                    }
                }
                .padding(.horizontal, 24)
                
                // Login Button
                Button(action: {
                    loginUser()
                }) {
                    Text("Login")
                        .font(.system(size: 16))
                        .foregroundColor(white)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(buttonDefault)
                        .cornerRadius(8)
                }
                .padding(.horizontal, 24)
                
                Spacer().frame(height: 20)
                
                // Signup & Forgot Password Links
                VStack(spacing: 10) {
                    NavigationLink(destination: SignupView()) {
                        Text("Haven't Registered? Signup")
                            .foregroundColor(primaryColor)
                            .fontWeight(.bold)
                    }
                    NavigationLink(destination: PasswordResetView()) {
                        Text("Forgot Your Password? Reset It.")
                            .foregroundColor(primaryColor)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
            }
            .navigationBarBackButtonHidden(true) // Disables the default back button
            .navigationDestination(isPresented: $navigateToHome) {
                if let destination = destinationView {
                    destination
                        .navigationBarBackButtonHidden(true)
                } else {
                    EmptyView()
                }
            }
            .alert(isPresented: $showError) {
                Alert(title: Text("Login Error"),
                      message: Text(errorMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    // MARK: - Firebase Login Functionality
    func loginUser() {
        // Validate form fields
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Enter your email and password"
            showError = true
            return
        }
        
        isLoading = true
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                errorMessage = "Login failed! Check your credentials. \(error.localizedDescription)"
                showError = true
            } else if let user = authResult?.user {
                validateUserRole(uid: user.uid)
            }
        }
    }
    
    func validateUserRole(uid: String) {
        let db = Firestore.firestore()
        db.collection("users").document(uid).getDocument { document, error in
            if let document = document, document.exists {
                let data = document.data()
                let role = data?["role"] as? String ?? "customer"
                DispatchQueue.main.async {
                    switch role {
                    case "customer":
                        destinationView = AnyView(CustomerHomeView())
                    case "driver":
                        destinationView = AnyView(DriverHomeView())
                    case "restaurant":
                        destinationView = AnyView(RestaurantHomeView())
                    case "admin":
                        destinationView = AnyView(AdminHomeView())
                    default:
                        destinationView = AnyView(CustomerHomeView())
                    }
                    navigateToHome = true
                }
            } else {
                errorMessage = "User role not found!"
                showError = true
            }
        }
    }
}

// MARK: - Color Extension for Hex Colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}



// MARK: - Preview Provider
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
