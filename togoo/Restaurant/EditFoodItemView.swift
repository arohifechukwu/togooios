//
//  EditFoodItemView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth

struct EditFoodItemView: View {
    @Environment(\.dismiss) var dismiss

    let restaurantId: String
    let parentNode: String
    let category: String?
    let foodId: String

    @State private var id: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var image: UIImage? = nil
    @State private var imageURL: String = ""
    @State private var showImagePicker = false
    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                }
                Text("Edit Food Item")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .background(Color.primaryVariant)

            // Inside ScrollView -> VStack:
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let image = image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        Image("burger")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(12)
                            .opacity(0.3)
                    }

                    // Pick Image (centered)
                    HStack {
                        Spacer()
                        Button("Pick Image") {
                            showImagePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.primaryVariant)
                        Spacer()
                    }

                    // ID (left-aligned)
                    Text(id)
                        .font(.headline)
                        .padding(.horizontal)

                    // Description
                    TextField("Description", text: $description)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    // Price
                    TextField("Price", text: $price)
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)

                    // Message
                    if !message.isEmpty {
                        Text(message)
                            .foregroundColor(.red)
                            .padding(.top, 4)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            // Fixed Save Button
            HStack {
                Spacer()
                Button("Save Changes") {
                    saveChanges()
                }
                .buttonStyle(.borderedProminent)
                .tint(.primaryVariant)
                Spacer()
            }
            .padding()
            .background(Color(.systemGroupedBackground))
        }
        .onAppear(perform: loadFoodItem)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
        .navigationBarBackButtonHidden(true)
        .background(Color(.systemGroupedBackground))
    }

    func loadFoodItem() {
        let ref: DatabaseReference
        if parentNode == "menu", let category = category {
            ref = Database.database().reference()
                .child("restaurant")
                .child(restaurantId)
                .child("menu")
                .child(category)
                .child(foodId)
        } else {
            ref = Database.database().reference()
                .child("restaurant")
                .child(restaurantId)
                .child(parentNode)
                .child(foodId)
        }

        ref.observeSingleEvent(of: .value) { snapshot in
            if let data = snapshot.value as? [String: Any] {
                id = data["id"] as? String ?? foodId
                description = data["description"] as? String ?? ""
                price = String(data["price"] as? Double ?? 0.0)
                imageURL = data["imageURL"] as? String ?? ""

                if let url = URL(string: imageURL) {
                    URLSession.shared.dataTask(with: url) { data, _, _ in
                        if let data = data, let uiImg = UIImage(data: data) {
                            DispatchQueue.main.async {
                                image = uiImg
                            }
                        }
                    }.resume()
                }
            }
        }
    }

    func saveChanges() {
        guard !description.isEmpty, !price.isEmpty, let priceVal = Double(price) else {
            showTemporaryMessage("Please complete all fields.")
            return
        }

        let ref: DatabaseReference
        if parentNode == "menu", let category = category {
            ref = Database.database().reference()
                .child("restaurant")
                .child(restaurantId)
                .child("menu")
                .child(category)
                .child(foodId)
        } else {
            ref = Database.database().reference()
                .child("restaurant")
                .child(restaurantId)
                .child(parentNode)
                .child(foodId)
        }

        var updates: [String: Any] = [
            "description": description,
            "price": priceVal
        ]

        if let image = image, let data = image.jpegData(compressionQuality: 0.8) {
            let storageRef = Storage.storage().reference()
                .child("restaurant_menu_images/\(restaurantId)/\(UUID().uuidString).jpg")

            storageRef.putData(data, metadata: nil) { _, error in
                if let error = error {
                    showTemporaryMessage("Image upload failed: \(error.localizedDescription)")
                    return
                }
                storageRef.downloadURL { url, _ in
                    guard let url = url else { return }
                    updates["imageURL"] = url.absoluteString
                    ref.updateChildValues(updates)
                    showTemporaryMessage("Food item updated")
                }
            }
        } else {
            ref.updateChildValues(updates)
            showTemporaryMessage("Food item updated")
        }
    }

    func showTemporaryMessage(_ text: String) {
        message = text
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            message = ""
        }
    }
}

#Preview {
    EditFoodItemView(
        restaurantId: "mock_restaurant",
        parentNode: "Special Offers",
        category: nil,
        foodId: "Coke123"
    )
}
