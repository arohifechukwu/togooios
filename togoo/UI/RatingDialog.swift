//
//  RatingDialog.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-14.
//


import SwiftUI
import FirebaseDatabase
import FirebaseAuth

struct RatingDialog: View {
    let order: NotificationsView.OrderLog
    @Environment(\.dismiss) var dismiss
    @State private var restaurantRating: Double = 3.0
    @State private var driverRating: Double = 3.0
    @State private var restaurantComment = ""
    @State private var driverComment = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Your feedback helps us improve")
                        .font(.title3.bold())
                        .padding(.bottom)

                    Group {
                        Text("Rate the Restaurant")
                        RatingView(rating: $restaurantRating)

                        TextField("Leave a comment for the restaurant", text: $restaurantComment, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                    }

                    Group {
                        Text("Rate the Driver")
                        RatingView(rating: $driverRating)

                        TextField("Leave a comment for the driver", text: $driverComment, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(2...4)
                    }

                    Button("Submit") {
                        submitRatings()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.primaryVariant)
                    .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Rate Your Order")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func submitRatings() {
        let db = Database.database().reference()
        let now = ISO8601DateFormatter().string(from: Date())
        guard let userId = Auth.auth().currentUser?.uid else { return }

        let restaurantRatingData: [String: Any] = [
            "value": restaurantRating,
            "comment": restaurantComment,
            "timestamp": now
        ]

        let driverRatingData: [String: Any] = [
            "value": driverRating,
            "comment": driverComment,
            "timestamp": now
        ]

        db.child("restaurant").child(order.orderId).child("ratings").child(userId).setValue(restaurantRatingData)
        if let driverId = order.driverId {
            db.child("driver").child(driverId).child("ratings").child(userId).setValue(driverRatingData)
        }

        dismiss()
    }
}

struct RatingView: View {
    @Binding var rating: Double

    var body: some View {
        HStack {
            ForEach(1..<6) { star in
                Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                    .foregroundColor(.yellow)
                    .onTapGesture {
                        rating = Double(star)
                    }
            }
        }
    }
}

struct DriverInfoDialog: View {
    let driverId: String
    let estimatedTime: String
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var phone = ""
    @State private var plate = ""
    @State private var brand = ""
    @State private var model = ""
    @State private var imageURL = ""
    @State private var carURL = ""

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                AsyncImage(url: URL(string: imageURL)) { img in
                    img.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 100, height: 100)
                .clipShape(Circle())
                .padding(.top)

                Text("Name: \(name)").bold()
                Text("Phone: \(phone)")
                Text("License Plate: \(plate)")
                Text("Car Type: \(brand)")
                Text("Model: \(model)")
                Text("ETA: \(estimatedTime)")

                AsyncImage(url: URL(string: carURL)) { img in
                    img.resizable()
                } placeholder: {
                    Color.gray
                }
                .frame(width: 200, height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.bottom)
            }
            .padding()
        }
        .onAppear(perform: fetchDriverInfo)
    }

    private func fetchDriverInfo() {
        let ref = Database.database().reference().child("driver").child(driverId)
        ref.observeSingleEvent(of: .value) { snap in
            name = snap.childSnapshot(forPath: "name").value as? String ?? ""
            phone = snap.childSnapshot(forPath: "phone").value as? String ?? ""
            plate = snap.childSnapshot(forPath: "licensePlate").value as? String ?? ""
            brand = snap.childSnapshot(forPath: "carBrand").value as? String ?? ""
            model = snap.childSnapshot(forPath: "carModel").value as? String ?? ""
            imageURL = snap.childSnapshot(forPath: "imageURL").value as? String ?? ""
            carURL = snap.childSnapshot(forPath: "carPicture").value as? String ?? ""
        }
    }
}