//
//  RegistrationView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-07.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct RegistrationView: View {
    // MARK: - Basic Fields
    @State private var fullName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    // MARK: - Business Type
    @State private var businessType: String = ""
    let businessTypes = ["Driver", "Restaurant"]
    
    // MARK: - Dynamic License Fields (for file selection or URL input)
    // For Driver
    @State private var driverLicenseURL: URL? = nil
    @State private var driverLicenseInput: String = ""
    @State private var vehicleRegistrationURL: URL? = nil
    @State private var vehicleRegistrationInput: String = ""
    // For Restaurant
    @State private var restaurantLicenseURL: URL? = nil
    @State private var restaurantLicenseInput: String = ""
    @State private var retailLicenseURL: URL? = nil
    @State private var retailLicenseInput: String = ""
    
    // MARK: - Terms & Conditions
    @State private var termsAccepted: Bool = false
    
    // MARK: - Alert & Navigation
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    // We'll navigate to a "RegistrationStatusView" after successful registration (status pending)
    @State private var navigateToStatus: Bool = false
    
    // MARK: - Loading State
    @State private var isLoading: Bool = false
    
    // MARK: - File Picker Management
    @State private var showDocumentPicker: Bool = false
    @State private var currentFileField: FileField = .none
    
    enum FileField {
        case none, driverLicense, vehicleRegistration, restaurantLicense, retailLicense
    }
    
    // MARK: - Password Visibility Toggles
    @State private var passwordVisible: Bool = false
    @State private var confirmPasswordVisible: Bool = false
    
    // MARK: - Upload Counters
    @State private var expectedUploads: Int = 0
    @State private var uploadCount: Int = 0
    
    // MARK: - Color Palette (using Color(hex:) from Color+Hex.swift)
    let primaryColor = Color(hex: "F18D34")       // Dark Orange
    let primaryVariant = Color(hex: "E67E22")       // Slightly Darker Orange
    let secondaryColor = Color(hex: "FF9800")       // Lighter Orange
    let white = Color.white
    let lightGray = Color(hex: "F5F5F5")
    let darkGray = Color(hex: "757575")
    let black = Color.black
    let buttonDefault = Color(hex: "F18D34")
    let buttonPressed = Color(hex: "E67E22")
    let buttonDisabled = Color(hex: "FFB066")
    
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Spacer().frame(height: 40)
                    
                    // Logo & Slogan
                    Image("logo")
                        .resizable()
                        .frame(width: 150, height: 150)
                    Text("Bringing Your Cravings Home!")
                        .font(.system(size: 18))
                        .italic()
                        .foregroundColor(darkGray)
                        .multilineTextAlignment(.center)
                    
                    // Basic Info Fields
                    Group {
                        customTextField(placeholder: "Full Name", text: $fullName)
                        customTextField(placeholder: "Email", text: $email, keyboardType: .emailAddress)
                        customTextField(placeholder: "Phone", text: $phone, keyboardType: .phonePad)
                        customTextField(placeholder: "Address", text: $address)
                        customPasswordField(placeholder: "Password", text: $password, isVisible: $passwordVisible)
                        customPasswordField(placeholder: "Confirm Password", text: $confirmPassword, isVisible: $confirmPasswordVisible)
                    }
                    .padding(.horizontal, 24)
                    
                    // Password Validation Guide
                    Text("Password must be at least 6 characters and contain letters, numbers, and symbols (e.g., P@ssw0rd!)")
                        .font(.system(size: 14))
                        .foregroundColor(darkGray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                    
                    // Business Type Picker
                    Picker("Business Type", selection: $businessType) {
                        Text("Select Business Type").tag("")
                        ForEach(businessTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 24)
                    
                    // Dynamic Fields Based on Business Type
                    if businessType.lowercased() == "driver" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Driver Information")
                                .font(.headline)
                                .foregroundColor(black)
                            
                            // Driver License Field
                            HStack {
                                Button(action: {
                                    currentFileField = .driverLicense
                                    showDocumentPicker = true
                                }) {
                                    Text("Select Driver License")
                                        .foregroundColor(primaryColor)
                                }
                                if let url = driverLicenseURL {
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(darkGray)
                                }
                            }
                            customTextField(placeholder: "Or enter Driver License URL (optional)", text: $driverLicenseInput)
                            
                            // Vehicle Registration Field
                            HStack {
                                Button(action: {
                                    currentFileField = .vehicleRegistration
                                    showDocumentPicker = true
                                }) {
                                    Text("Select Vehicle Registration")
                                        .foregroundColor(primaryColor)
                                }
                                if let url = vehicleRegistrationURL {
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(darkGray)
                                }
                            }
                            customTextField(placeholder: "Or enter Vehicle Registration URL (optional)", text: $vehicleRegistrationInput)
                        }
                        .padding(.horizontal, 24)
                    } else if businessType.lowercased() == "restaurant" {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Restaurant Information")
                                .font(.headline)
                                .foregroundColor(black)
                            
                            // Restaurant License Field
                            HStack {
                                Button(action: {
                                    currentFileField = .restaurantLicense
                                    showDocumentPicker = true
                                }) {
                                    Text("Select Restaurant License")
                                        .foregroundColor(primaryColor)
                                }
                                if let url = restaurantLicenseURL {
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(darkGray)
                                }
                            }
                            customTextField(placeholder: "Or enter Restaurant License URL (optional)", text: $restaurantLicenseInput)
                            
                            // Retail License Field
                            HStack {
                                Button(action: {
                                    currentFileField = .retailLicense
                                    showDocumentPicker = true
                                }) {
                                    Text("Select Retail License")
                                        .foregroundColor(primaryColor)
                                }
                                if let url = retailLicenseURL {
                                    Text(url.lastPathComponent)
                                        .font(.caption)
                                        .foregroundColor(darkGray)
                                }
                            }
                            customTextField(placeholder: "Or enter Retail License URL (optional)", text: $retailLicenseInput)
                        }
                        .padding(.horizontal, 24)
                    }
                    
                    // Terms & Conditions
                    Toggle("I agree to the Terms & Conditions", isOn: $termsAccepted)
                        .padding(.horizontal, 24)
                        .foregroundColor(darkGray)
                    
                    // Register Button
                    Button(action: {
                        registerBusiness()
                    }) {
                        Text("Register Business")
                            .font(.system(size: 16))
                            .foregroundColor(white)
                            .frame(maxWidth: .infinity, minHeight: 50)
                            .background(buttonDefault)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                // Custom back navigation button using environment dismiss
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToStatus) {
                RegistrationStatusView().navigationBarBackButtonHidden(true)
            }
            .alert("Registration Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showDocumentPicker) {
                DocumentPicker { url in
                    if let url = url {
                        switch currentFileField {
                        case .driverLicense:
                            driverLicenseURL = url
                        case .vehicleRegistration:
                            vehicleRegistrationURL = url
                        case .restaurantLicense:
                            restaurantLicenseURL = url
                        case .retailLicense:
                            retailLicenseURL = url
                        default:
                            break
                        }
                    }
                    showDocumentPicker = false
                }
            }
        }
    }
    
    // MARK: - Helper View Builders
    func customTextField(placeholder: String, text: Binding<String>, keyboardType: UIKeyboardType = .default) -> some View {
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
    
    /// Custom Password Field with Visibility Toggle
    func customPasswordField(placeholder: String, text: Binding<String>, isVisible: Binding<Bool>) -> some View {
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
    
    func customSecureField(placeholder: String, text: Binding<String>) -> some View {
        SecureField(placeholder, text: text)
            .padding()
            .background(lightGray)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(darkGray, lineWidth: 1)
            )
            .padding(.bottom, 10)
    }
    
    // MARK: - Firebase Registration Functionality
    func registerBusiness() {
        // Validate required fields
        guard !fullName.isEmpty,
              !email.isEmpty,
              !phone.isEmpty,
              !address.isEmpty,
              !password.isEmpty,
              !confirmPassword.isEmpty else {
            alertMessage = "All fields are required."
            showAlert = true
            return
        }
        guard password == confirmPassword else {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        guard isValidPassword(password) else {
            alertMessage = "Password must be at least 6 characters and include letters, numbers, and symbols."
            showAlert = true
            return
        }
        guard termsAccepted else {
            alertMessage = "You must accept the Terms & Conditions."
            showAlert = true
            return
        }
        
        isLoading = true
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            isLoading = false
            if let error = error {
                alertMessage = "Registration failed: \(error.localizedDescription)"
                showAlert = true
                return
            }
            
            guard let uid = authResult?.user.uid else { return }
            let businessNode = businessType.lowercased()  // "driver" or "restaurant"
            let userRef = Database.database().reference().child(businessNode).child(uid)
            
            // Prepare user data and set registration status as pending
            var userData: [String: Any] = [
                "name": fullName,
                "email": email,
                "phone": phone,
                "address": address,
                "role": businessType,
                "status": "pending",
                "createdAt": ServerValue.timestamp()
            ]
            
            let storageRef = Storage.storage().reference()
            expectedUploads = 0
            uploadCount = 0
            
            func checkAndUpdate() {
                uploadCount += 1
                if uploadCount == expectedUploads {
                    updateUserRecord(userRef: userRef, userData: userData)
                }
            }
            
            if businessType.lowercased() == "driver" {
                // Driver License
                if let fileURL = driverLicenseURL {
                    expectedUploads += 1
                    let fileRef = storageRef.child("driver").child("\(uid)_driverLicense.jpg")
                    fileRef.putFile(from: fileURL, metadata: nil) { _, error in
                        if let error = error {
                            alertMessage = "Failed to upload Driver License: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        fileRef.downloadURL { url, _ in
                            if let url = url {
                                userData["driverLicense"] = url.absoluteString
                            } else {
                                userData["driverLicense"] = driverLicenseInput
                            }
                            checkAndUpdate()
                        }
                    }
                } else {
                    userData["driverLicense"] = driverLicenseInput
                    expectedUploads += 1
                    checkAndUpdate()
                }
                // Vehicle Registration
                if let fileURL = vehicleRegistrationURL {
                    expectedUploads += 1
                    let fileRef = storageRef.child("driver").child("\(uid)_vehicleRegistration.jpg")
                    fileRef.putFile(from: fileURL, metadata: nil) { _, error in
                        if let error = error {
                            alertMessage = "Failed to upload Vehicle Registration: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        fileRef.downloadURL { url, _ in
                            if let url = url {
                                userData["vehicleRegistration"] = url.absoluteString
                            } else {
                                userData["vehicleRegistration"] = vehicleRegistrationInput
                            }
                            checkAndUpdate()
                        }
                    }
                } else {
                    userData["vehicleRegistration"] = vehicleRegistrationInput
                    expectedUploads += 1
                    checkAndUpdate()
                }
            } else if businessType.lowercased() == "restaurant" {
                // Restaurant License
                if let fileURL = restaurantLicenseURL {
                    expectedUploads += 1
                    let fileRef = storageRef.child("restaurant").child("\(uid)_restaurantLicense.jpg")
                    fileRef.putFile(from: fileURL, metadata: nil) { _, error in
                        if let error = error {
                            alertMessage = "Failed to upload Restaurant License: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        fileRef.downloadURL { url, _ in
                            if let url = url {
                                userData["restaurantLicense"] = url.absoluteString
                            } else {
                                userData["restaurantLicense"] = restaurantLicenseInput
                            }
                            checkAndUpdate()
                        }
                    }
                } else {
                    userData["restaurantLicense"] = restaurantLicenseInput
                    expectedUploads += 1
                    checkAndUpdate()
                }
                // Retail License
                if let fileURL = retailLicenseURL {
                    expectedUploads += 1
                    let fileRef = storageRef.child("restaurant").child("\(uid)_retailLicense.jpg")
                    fileRef.putFile(from: fileURL, metadata: nil) { _, error in
                        if let error = error {
                            alertMessage = "Failed to upload Retail License: \(error.localizedDescription)"
                            showAlert = true
                            return
                        }
                        fileRef.downloadURL { url, _ in
                            if let url = url {
                                userData["retailLicense"] = url.absoluteString
                            } else {
                                userData["retailLicense"] = retailLicenseInput
                            }
                            checkAndUpdate()
                        }
                    }
                } else {
                    userData["retailLicense"] = retailLicenseInput
                    expectedUploads += 1
                    checkAndUpdate()
                }
            } else {
                updateUserRecord(userRef: userRef, userData: userData)
            }
            
            // If no uploads are needed, update user record immediately.
            if expectedUploads == 0 {
                updateUserRecord(userRef: userRef, userData: userData)
            }
        }
    }
    
    func updateUserRecord(userRef: DatabaseReference, userData: [String: Any]) {
        userRef.setValue(userData) { error, _ in
            if let error = error {
                alertMessage = "Registration update failed: \(error.localizedDescription)"
                showAlert = true
            } else {
                // Navigate to a status view showing pending registration
                navigateToStatus = true
            }
        }
    }
    
    /// Password Validation: must be at least 6 characters, include letters, numbers, and symbols.
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)(?=.*[@#$%^&+=!]).{6,}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: password)
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
