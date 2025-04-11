//
//  RatingDialogView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI
import FirebaseAuth

struct RatingDialogView: View {
    var orderId: String
    var restaurantId: String
    var driverId: String
    var onSubmit: (String, String, String, Float, String) -> Void

    @State private var restaurantRating: Float = 0
    @State private var driverRating: Float = 0
    @State private var restaurantComment: String = ""
    @State private var driverComment: String = ""

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Rate Your Order")
                    .font(.title2)
                    .bold()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rate the Restaurant")
                    RatingBar(rating: $restaurantRating)
                    TextField("Leave a comment for the restaurant", text: $restaurantComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rate the Driver")
                    RatingBar(rating: $driverRating)
                    TextField("Leave a comment for the driver", text: $driverComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button("Submit") {
                    if let customerId = Auth.auth().currentUser?.uid {
                        onSubmit("restaurant", restaurantId, customerId, restaurantRating, restaurantComment)
                        onSubmit("driver", driverId, customerId, driverRating, driverComment)
                    }
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}

struct RatingBar: View {
    @Binding var rating: Float
    var maximumRating: Int = 5

    var body: some View {
        HStack {
            ForEach(1...maximumRating, id: \ .self) { star in
                Image(systemName: star <= Int(rating.rounded()) ? "star.fill" : "star")
                    .foregroundColor(.orange)
                    .onTapGesture {
                        rating = Float(star)
                    }
            }
        }
    }
}