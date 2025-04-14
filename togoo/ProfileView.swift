//
//  ProfileView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//


import SwiftUI
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct ProfileView: View {
    @Environment(\.dismiss) var dismiss

    // User Info
    @State private var name = ""
    @State private var address = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var image: UIImage? = nil
    @State private var imageURL: String? = nil
    @State private var showImagePicker = false
    @State private var userRole: String? = nil
    @State private var userRef: DatabaseReference? = nil
    @State private var showAlert = false
    @State private var alertMessage = ""

    let primaryColor = Color(hex: "F18D34")
    let backgroundColor = Color.white
    let storageRef = Storage.storage().reference(withPath: "ProfilePictures")

    var body: some View {
        VStack(spacing: 0) {
            // Title Bar with custom back
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.headline)
                    Text("Back")
                        .foregroundColor(.white)
                        .font(.subheadline)
                }
                Spacer()
                Text("Profile")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Spacer().frame(width: 60) // to balance the Back button
            }
            .padding()
            .background(primaryColor)

            ScrollView {
                VStack(spacing: 16) {
                    profileImageSection
                    formFieldsSection
                    saveButton
                }
                .padding(.bottom)
            }

            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .background(backgroundColor.edgesIgnoringSafeArea(.all))
        .onAppear(perform: fetchUserInfo)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Profile Update"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    private var profileImageSection: some View {
        VStack {
            Button(action: { showImagePicker = true }) {
                if let image = image {
                    Image(uiImage: image).resizable().scaledToFill()
                } else {
                    AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFill()
                        } else {
                            Image("ic_account2").resizable().scaledToFill()
                        }
                    }
                }
            }
            .frame(width: 120, height: 120)
            .clipShape(Circle())
            .shadow(radius: 4)
            .padding(.top)

            Button("Upload Profile Picture") {
                showImagePicker = true
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 18)
            .background(primaryColor)
            .foregroundColor(.black)
            .cornerRadius(10)
        }
    }

    private var formFieldsSection: some View {
        Group {
            TextField("Full Name", text: $name)
            TextField("Address", text: $address)
            TextField("Phone Number", text: $phone)
                .keyboardType(.phonePad)
            TextField("Email", text: $email)
                .disabled(true)
                .foregroundColor(.gray.opacity(0.8))
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal)
    }

    private var saveButton: some View {
        Button("Save Changes") {
            uploadImageIfNeededAndSave()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(primaryColor)
        .foregroundColor(.black)
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private func fetchUserInfo() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        email = Auth.auth().currentUser?.email ?? ""
        let roles = ["driver", "customer", "admin", "restaurant"]
        let db = Database.database().reference()

        for role in roles {
            let ref = db.child(role).child(uid)
            ref.observeSingleEvent(of: .value) { snapshot in
                if snapshot.exists() {
                    userRef = ref
                    userRole = role
                    if let value = snapshot.value as? [String: Any] {
                        name = value["name"] as? String ?? ""
                        address = value["address"] as? String ?? ""
                        phone = value["phone"] as? String ?? ""
                        imageURL = value["imageURL"] as? String ?? ""
                    }
                }
            }
        }
    }

    private func uploadImageIfNeededAndSave() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if let image = image, let imageData = image.jpegData(compressionQuality: 0.8) {
            let imageRef = storageRef.child("\(uid).jpg")
            imageRef.putData(imageData) { _, error in
                if error == nil {
                    imageRef.downloadURL { url, _ in
                        imageURL = url?.absoluteString
                        updateUserData()
                    }
                } else {
                    alertMessage = "❌ Image upload failed"
                    showAlert = true
                }
            }
        } else {
            updateUserData()
        }
    }

    private func updateUserData() {
        guard let ref = userRef else { return }
        let updates: [String: Any] = [
            "name": name,
            "address": address,
            "phone": phone,
            "imageURL": imageURL ?? ""
        ]
        ref.updateChildValues(updates) { error, _ in
            alertMessage = error == nil ? "✅ Profile updated successfully" : "❌ Update failed"
            showAlert = true
        }
    }

    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            let parent: ImagePicker
            init(_ parent: ImagePicker) { self.parent = parent }

            func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
                if let uiImage = info[.originalImage] as? UIImage {
                    parent.image = uiImage
                }
                picker.dismiss(animated: true)
            }
        }

        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
