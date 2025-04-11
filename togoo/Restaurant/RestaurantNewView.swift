//
//  RestaurantNewView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

struct RestaurantNewView: View {
    @Environment(\.dismiss) var dismiss

    @State private var nodeOptions = ["Special Offers", "Top Picks", "New Menu Category", "Update Menu Category"]
    @State private var selectedNode = "Special Offers"

    @State private var foodId = ""
    @State private var description = ""
    @State private var price = ""
    @State private var category = ""
    @State private var selectedExistingCategory = ""
    @State private var categoryList: [String] = []

    @State private var image: UIImage? = nil
    @State private var showImagePicker = false
    @State private var imageUrl: URL? = nil

    @State private var message: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Custom Top Bar
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(.trailing, 4)
                    }

                    Text("Create Food Item")
                        .font(.title3.bold())
                        .foregroundColor(.white)

                    Spacer()
                }
                .padding()
                .background(Color.primaryVariant)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Select Section", selection: $selectedNode) {
                            ForEach(nodeOptions, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)

                        TextField("Food ID", text: $foodId)
                            .textFieldStyle(.roundedBorder)
                        TextField("Description", text: $description)
                            .textFieldStyle(.roundedBorder)
                        TextField("Price (e.g. 12.50)", text: $price)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)

                        if selectedNode == "New Menu Category" {
                            TextField("New Category Name", text: $category)
                                .textFieldStyle(.roundedBorder)
                        } else if selectedNode == "Update Menu Category" {
                            Picker("Select Existing Category", selection: $selectedExistingCategory) {
                                ForEach(categoryList, id: \.self) { Text($0) }
                            }
                            .onAppear(perform: fetchCategories)
                        }

                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(Text("No image selected"))
                        }

                        Button("Pick Image") { showImagePicker = true }

                        Button("Create Food Item") {
                            createFoodItem()
                        }
                        .buttonStyle(.borderedProminent)

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(.red)
                                .padding(.top)
                        }
                    }
                    .padding()
                }

                RestaurantBottomNavigationView(selectedTab: "new") { _ in }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    func fetchCategories() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference().child("restaurant").child(uid).child("menu").observeSingleEvent(of: .value) { snapshot in
            categoryList = snapshot.children.compactMap { ($0 as? DataSnapshot)?.key }
            if categoryList.isEmpty { selectedExistingCategory = "" }
            else if !categoryList.contains(selectedExistingCategory) {
                selectedExistingCategory = categoryList.first ?? ""
            }
        }
    }

    func createFoodItem() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !foodId.isEmpty, !description.isEmpty, !price.isEmpty, let priceVal = Double(price), let image = image else {
            message = "All fields are required"
            return
        }

        let storageRef = Storage.storage().reference().child("restaurant_menu_images").child(uid).child(UUID().uuidString + ".jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        let selectedCategory = selectedNode == "New Menu Category" ? category : selectedNode == "Update Menu Category" ? selectedExistingCategory : ""
        let nodePath = selectedNode == "New Menu Category" || selectedNode == "Update Menu Category" ? "menu/\(selectedCategory)" : selectedNode

        let ref = Database.database().reference().child("restaurant").child(uid).child(nodePath).child(foodId)

        ref.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                message = "A food item with this ID already exists."
                return
            }

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    message = "Upload failed: \(error.localizedDescription)"
                    return
                }

                storageRef.downloadURL { url, err in
                    guard let downloadURL = url else {
                        message = "Failed to get image URL"
                        return
                    }

                    let item: [String: Any] = [
                        "foodId": foodId,
                        "foodDescription": description,
                        "imageURL": downloadURL.absoluteString,
                        "restaurantId": uid,
                        "price": priceVal
                    ]

                    ref.setValue(item) { err, _ in
                        if let err = err {
                            message = "Database error: \(err.localizedDescription)"
                        } else {
                            message = "Food item added successfully"
                            clearFields()
                        }
                    }
                }
            }
        }
    }

    func clearFields() {
        foodId = ""
        description = ""
        price = ""
        category = ""
        selectedExistingCategory = ""
        image = nil
    }
}
