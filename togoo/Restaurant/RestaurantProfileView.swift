//
//  RestaurantProfileView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage
import CoreLocation

struct RestaurantProfileView: View {
    @Binding var backDestination: Bool
    @Environment(\.dismiss) var dismiss

    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var image: UIImage? = nil
    @State private var imageURL: String = ""
    @State private var showImagePicker = false
    @State private var message = ""

    @State private var hours: [String: (String, String)] = [:]
    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private var restaurantId: String { Auth.auth().currentUser?.uid ?? "" }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Restaurant's Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.primaryVariant)

            ScrollView {
                VStack(spacing: 16) {
                    // Profile Image
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                    } else {
                        Image("ic_restaurant_placeholder")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .opacity(0.3)
                    }

                    Button("Change Image") {
                        showImagePicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)

                    // Info Fields
                    Group {
                        TextField("Restaurant Name", text: $name)
                        TextField("Address", text: $address)
                        TextField("Phone", text: $phone)
                        TextField("Email", text: .constant(email))
                            .disabled(true)
                            .foregroundColor(.gray)
                    }
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)

                    // Hours
                    Text("Operating Hours")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)

                    ForEach(days, id: \.self) { day in
                        HStack {
                            Text(day)
                                .frame(width: 90, alignment: .leading)
                            TextField("Open", text: Binding(
                                get: { hours[day]?.0 ?? "" },
                                set: { hours[day] = ($0, hours[day]?.1 ?? "") }
                            ))
                            .textFieldStyle(.roundedBorder)
                            TextField("Close", text: Binding(
                                get: { hours[day]?.1 ?? "" },
                                set: { hours[day] = (hours[day]?.0 ?? "", $0) }
                            ))
                            .textFieldStyle(.roundedBorder)
                        }
                        .padding(.horizontal)
                    }

                    // Message
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                    }

                    // Save Button
                    Button("Save Changes") {
                        saveProfileData()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)
                    .padding(.vertical)
                }
                .padding()
            }
        }
        .onAppear(perform: loadProfileData)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
    }

    private func loadProfileData() {
        let ref = Database.database().reference().child("restaurant").child(restaurantId)
        ref.observeSingleEvent(of: .value) { snapshot in
            name = snapshot.childSnapshot(forPath: "name").value as? String ?? ""
            address = snapshot.childSnapshot(forPath: "address").value as? String ?? ""
            phone = snapshot.childSnapshot(forPath: "phone").value as? String ?? ""
            email = snapshot.childSnapshot(forPath: "email").value as? String ?? ""
            imageURL = snapshot.childSnapshot(forPath: "imageURL").value as? String ?? ""

            if let url = URL(string: imageURL) {
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    if let data = data, let uiImg = UIImage(data: data) {
                        DispatchQueue.main.async {
                            image = uiImg
                        }
                    }
                }.resume()
            }

            for day in days {
                let open = snapshot.childSnapshot(forPath: "operatingHours/\(day)/open").value as? String ?? ""
                let close = snapshot.childSnapshot(forPath: "operatingHours/\(day)/close").value as? String ?? ""
                hours[day] = (open, close)
            }
        }
    }

    private func saveProfileData() {
        guard !name.isEmpty, !address.isEmpty, !phone.isEmpty else {
            showTemporaryMessage("Please fill in all required fields.")
            return
        }

        let ref = Database.database().reference().child("restaurant").child(restaurantId)
        ref.child("name").setValue(name)
        ref.child("address").setValue(address)
        ref.child("phone").setValue(phone)

        for (day, (open, close)) in hours {
            ref.child("operatingHours").child(day).child("open").setValue(open)
            ref.child("operatingHours").child(day).child("close").setValue(close)
        }

        updateCoordinatesFromAddress(address, for: ref)

        if let image = image, let data = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference().child("restaurant_profile_images").child("\(restaurantId).jpg")
            storageRef.putData(data, metadata: nil) { _, err in
                if err == nil {
                    storageRef.downloadURL { url, _ in
                        if let url = url {
                            ref.child("imageURL").setValue(url.absoluteString)
                        }
                    }
                }
            }
        }

        showTemporaryMessage("Profile updated")
    }

    private func updateCoordinatesFromAddress(_ address: String, for ref: DatabaseReference) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, _ in
            guard let placemark = placemarks?.first,
                  let location = placemark.location else { return }
            ref.child("location").child("latitude").setValue(location.coordinate.latitude)
            ref.child("location").child("longitude").setValue(location.coordinate.longitude)
        }
    }

    private func showTemporaryMessage(_ text: String) {
        message = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = ""
        }
    }
}


#Preview {
    StateWrapper()
}

struct StateWrapper: View {
    @State private var nav = false

    var body: some View {
        RestaurantProfileView(backDestination: $nav)
    }
}
