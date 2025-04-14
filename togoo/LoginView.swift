//
// LoginView.swift
// togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase

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
            VStack(spacing: 16) {
                Spacer().frame(height: 40)
                
                // Logo
                Image("logo") // Ensure "logo" is in Assets.xcassets
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
                    // Optional action for the image
                }) {
                    Image("customer_login")
                        .resizable()
                        .frame(width: 50, height: 50)
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
                
                // Navigation Links
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
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToHome) {
                if let destination = destinationView {
                    destination.navigationBarBackButtonHidden(true)
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
        .onAppear {
            if let user = Auth.auth().currentUser {
                validateUserRole(uid: user.uid)
            }
        }
        
        }
    
    // MARK: - Firebase Login Functionality
    func loginUser() {
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
    
    // MARK: - Validate User Role Using Realtime Database
    func validateUserRole(uid: String) {
        let ref = Database.database().reference()
        // First check "customer" node
        ref.child("customer").child(uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                handleUserStatus(snapshot: snapshot, uid: uid)
            } else {
                // If not found, check "driver"
                checkUserRoleInNode(node: "driver", uid: uid, ref: ref)
            }
        } withCancel: { error in
            errorMessage = "Database error: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func checkUserRoleInNode(node: String, uid: String, ref: DatabaseReference) {
        ref.child(node).child(uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                handleUserStatus(snapshot: snapshot, uid: uid)
            } else {
                if node == "driver" {
                    checkUserRoleInNode(node: "restaurant", uid: uid, ref: ref)
                } else if node == "restaurant" {
                    checkUserRoleInNode(node: "admin", uid: uid, ref: ref)
                } else if node == "admin" {
                    checkAdminAccess(uid: uid)
                } else {
                    errorMessage = "User role not found!"
                    showError = true
                }
            }
        } withCancel: { error in
            errorMessage = "Database error: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func checkAdminAccess(uid: String) {
        let ref = Database.database().reference()
        ref.child("admin").child(uid).observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists(), let role = snapshot.childSnapshot(forPath: "role").value as? String, role.lowercased() == "admin" {
                navigateToDashboard(role: "admin")
            } else {
                errorMessage = "Access Denied: Not an Admin"
                showError = true
            }
        } withCancel: { error in
            errorMessage = "Database error: \(error.localizedDescription)"
            showError = true
        }
    }
    
    func handleUserStatus(snapshot: DataSnapshot, uid: String) {
        let role = snapshot.childSnapshot(forPath: "role").value as? String ?? "customer"
        let status = snapshot.childSnapshot(forPath: "status").value as? String ?? "approved"
        
        if status.lowercased() == "suspended" {
            errorMessage = "Account Suspended. Contact Administrator"
            showError = true
            return
        }
        
        if status.lowercased() == "deleted" {
            do {
                try Auth.auth().signOut()
            } catch { }
            errorMessage = "Account does not exist"
            showError = true
            return
        }
        
        if status.lowercased() == "pending" {
            destinationView = AnyView(RegistrationStatusView())
            navigateToHome = true
            return
        }
        
        navigateToDashboard(role: role)
    }
    
    func navigateToDashboard(role: String) {
        DispatchQueue.main.async {
            switch role.lowercased() {
            case "customer":
                destinationView = AnyView(CustomerHomeView())
            case "driver":
                destinationView = AnyView(DriverNotificationsView())
            case "restaurant":
                destinationView = AnyView(RestaurantHomeView())
            case "admin":
                destinationView = AnyView(AdminHomeView())
            default:
                destinationView = AnyView(CustomerHomeView())
            }
            navigateToHome = true
        }
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
