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
    @State private var message: String = ""
    @State private var messageColor: Color = .red

    @State private var navigateTo: AnyView? = nil
    @State private var navigate = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Text("Create Food Item")
                    .font(.title3.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryVariant)

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Picker("Select Section", selection: $selectedNode) {
                            ForEach(nodeOptions, id: \.self) { Text($0) }
                        }
                        .tint(.primaryVariant)
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
                        }

                        if selectedNode == "Update Menu Category" {
                            Picker("Select Existing Category", selection: $selectedExistingCategory) {
                                ForEach(categoryList, id: \.self) { category in
                                    Text(category).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primaryVariant)
                            .onAppear(perform: fetchCategories)
                        }

                        if let image = image {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .cornerRadius(12)
                                .frame(maxWidth: .infinity)
                        } else {
                            Image("ic_food_placeholder")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .opacity(0.3)
                                .frame(maxWidth: .infinity)
                        }

                        HStack {
                            Spacer()
                            Button("Pick Image") { showImagePicker = true }
                                .buttonStyle(.borderedProminent)
                                .tint(.primaryVariant)
                            Spacer()
                        }

                        HStack {
                            Spacer()
                            Button("Create Food Item") {
                                createFoodItem()
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.primaryVariant)
                            Spacer()
                        }

                        if !message.isEmpty {
                            Text(message)
                                .foregroundColor(messageColor)
                                .padding(.top)
                        }
                    }
                    .padding()
                }

                RestaurantBottomNavigationView(selectedTab: "new") {
                    navigateTo = $0
                    navigate = true
                }

                NavigationLink(destination: navigateTo, isActive: $navigate) {
                    EmptyView()
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
            .navigationBarBackButtonHidden(true)
            .background(Color(.systemGroupedBackground))
        }
    }

    func fetchCategories() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Database.database().reference()
            .child("restaurant")
            .child(uid)
            .child("menu")
            .observeSingleEvent(of: .value) { snapshot in
                categoryList = snapshot.children.compactMap { ($0 as? DataSnapshot)?.key }
                if categoryList.isEmpty {
                    selectedExistingCategory = ""
                } else if !categoryList.contains(selectedExistingCategory) {
                    selectedExistingCategory = categoryList.first ?? ""
                }
            }
    }

    func createFoodItem() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard !foodId.isEmpty, !description.isEmpty, !price.isEmpty,
              let priceVal = Double(price), let image = image else {
            message = "All fields are required"
            messageColor = .red
            return
        }

        let selectedCategory = selectedNode == "New Menu Category" ? category :
                               selectedNode == "Update Menu Category" ? selectedExistingCategory : ""

        if selectedNode.contains("Category") && selectedCategory.isEmpty {
            message = "Please provide a category name."
            messageColor = .red
            return
        }

        let nodePath = selectedNode.contains("Category") ? "menu/\(selectedCategory)" : selectedNode
        let foodRef = Database.database().reference()
            .child("restaurant")
            .child(uid)
            .child(nodePath)
            .child(foodId)

        foodRef.observeSingleEvent(of: .value) { snapshot in
            if snapshot.exists() {
                message = "A food item with this ID already exists."
                messageColor = .red
                return
            }

            guard let imageData = image.jpegData(compressionQuality: 0.8) else { return }

            let storageRef = Storage.storage().reference()
                .child("restaurant_menu_images")
                .child(uid)
                .child(UUID().uuidString + ".jpg")

            storageRef.putData(imageData, metadata: nil) { _, error in
                if let error = error {
                    message = "Image upload failed: \(error.localizedDescription)"
                    messageColor = .red
                    return
                }

                storageRef.downloadURL { url, _ in
                    guard let downloadURL = url else {
                        message = "Failed to get image URL"
                        messageColor = .red
                        return
                    }

                    let item: [String: Any] = [
                        "id": foodId,
                        "description": description,
                        "imageURL": downloadURL.absoluteString,
                        "restaurantId": uid,
                        "price": priceVal
                    ]

                    foodRef.setValue(item) { err, _ in
                        if let err = err {
                            message = "Database error: \(err.localizedDescription)"
                            messageColor = .red
                        } else {
                            message = "Food item added successfully"
                            messageColor = .red
                            clearFields()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                message = ""
                            }
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

#Preview {
    RestaurantNewView()
}

