//
//  DriverProfileView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

struct DriverProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var backToAccount: Bool

    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var carBrand = ""
    @State private var carModel = ""
    @State private var licensePlate = ""

    @State private var profileImage: UIImage? = nil
    @State private var carImage: UIImage? = nil
    @State private var profileImageURL = ""
    @State private var carImageURL = ""

    @State private var showProfilePicker = false
    @State private var showCarPicker = false
    @State private var message = ""

    var driverId: String { Auth.auth().currentUser?.uid ?? "" }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: {
                    backToAccount = false
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Driver Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.primaryVariant)

            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    ProfileImageView(image: profileImage, placeholder: "ic_account2") {
                        showProfilePicker = true
                    }

                    Button("Upload Profile Picture") {
                        showProfilePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)

                    FormField(label: "Full Name", text: $name)
                    FormField(label: "Address", text: $address)
                    FormField(label: "Phone Number", text: $phone)
                    FormField(label: "Email", text: .constant(email), disabled: true, textColor: .gray)
                    FormField(label: "Car Brand", text: $carBrand)
                    FormField(label: "Car Model", text: $carModel)
                    FormField(label: "License Plate", text: $licensePlate)

                    // Car Image
                    ProfileImageView(image: carImage, placeholder: "ic_car_placeholder") {
                        showCarPicker = true
                    }

                    Button("Upload Car Picture") {
                        showCarPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)

                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                    }

                    Button("Save Changes") {
                        saveProfile()
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)
                }
                .padding()
            }
        }
        .onAppear(perform: loadProfile)
        .sheet(isPresented: $showProfilePicker) {
            ImagePicker(image: $profileImage)
        }
        .sheet(isPresented: $showCarPicker) {
            ImagePicker(image: $carImage)
        }
        .navigationBarBackButtonHidden(true)
    }

    private func loadProfile() {
        let ref = Database.database().reference().child("driver").child(driverId)
        ref.observeSingleEvent(of: .value) { snapshot in
            name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            address = snapshot.childSnapshot(forPath: "address").value as? String ?? ""
            phone = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            email = snapshot.childSnapshot(forPath: "email").value as? String ?? ""
            carBrand = snapshot.childSnapshot(forPath: "carBrand").value as? String ?? ""
            carModel = snapshot.childSnapshot(forPath: "carModel").value as? String ?? ""
            licensePlate = snapshot.childSnapshot(forPath: "licensePlate").value as? String ?? ""
            profileImageURL = snapshot.childSnapshot(forPath: "imageURL").value as? String ?? ""
            carImageURL = snapshot.childSnapshot(forPath: "carPicture").value as? String ?? ""

            if let url = URL(string: profileImageURL) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async { self.profileImage = image }
                    }
                }.resume()
            }

            if let url = URL(string: carImageURL) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async { self.carImage = image }
                    }
                }.resume()
            }
        }
    }

    private func saveProfile() {
        guard !name.isEmpty, !address.isEmpty, !phone.isEmpty,
              !carBrand.isEmpty, !carModel.isEmpty, !licensePlate.isEmpty else {
            showTemporaryMessage("Please fill all fields.")
            return
        }

        let ref = Database.database().reference().child("driver").child(driverId)
        var updates: [String: Any] = [
            "name": name,
            "address": address,
            "phone": phone,
            "carBrand": carBrand,
            "carModel": carModel,
            "licensePlate": licensePlate
        ]

        if let profileImage = profileImage {
            uploadImage(image: profileImage, path: "DriverProfilePictures/\(driverId)_imageURL.jpg") { url in
                updates["imageURL"] = url
                ref.updateChildValues(updates)
            }
        }

        if let carImage = carImage {
            uploadImage(image: carImage, path: "DriverCarPictures/\(driverId)_carPicture.jpg") { url in
                updates["carPicture"] = url
                ref.updateChildValues(updates)
            }
        } else {
            ref.updateChildValues(updates)
        }

        showTemporaryMessage("Profile Updated Successfully")
    }

    private func uploadImage(image: UIImage, path: String, completion: @escaping (String) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return }
        let ref = Storage.storage().reference().child(path)
        ref.putData(data) { _, error in
            guard error == nil else { return }
            ref.downloadURL { url, _ in
                if let url = url {
                    completion(url.absoluteString)
                }
            }
        }
    }

    private func showTemporaryMessage(_ text: String) {
        message = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = ""
        }
    }
}

struct FormField: View {
    var label: String
    @Binding var text: String
    var disabled: Bool = false
    var textColor: Color = .black

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)

            TextField("", text: $text)
                .disabled(disabled)
                .foregroundColor(textColor)
                .textFieldStyle(.roundedBorder)
        }
    }
}


struct ProfileImageView: View {
    let image: UIImage?
    let placeholder: String
    let onTap: () -> Void

    var body: some View {
        ZStack {
            if let img = image {
                Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
            } else {
                Image(placeholder)
                    .resizable()
                    .scaledToFit()
                    .opacity(0.3)
            }
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .onTapGesture(perform: onTap)
    }
}


struct DriverProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DriverProfileView(backToAccount: .constant(false))
        }
    }
}
