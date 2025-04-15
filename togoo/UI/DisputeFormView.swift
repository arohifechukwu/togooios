//
//  DisputeFormView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct DisputeFormView: View {
    var orderId: String
    var onSubmit: (String, String, String, UIImage?) -> Void

    @State private var disputeTitle: String = ""
    @State private var disputeDescription: String = ""
    @State private var disputeReason: String = ""
    @State private var evidenceImage: UIImage?
    @State private var showImagePicker: Bool = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text("Dispute Form")
                    .font(.title2)
                    .bold()
                TextField("Dispute Title", text: $disputeTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Description", text: $disputeDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(height: 100)
                TextField("Reason", text: $disputeReason)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Upload Image") {
                    showImagePicker = true
                }
                .tint(Color.primaryVariant)
                
                if let image = evidenceImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .border(Color.gray, width: 1)
                }
                Button("Submit") {
                    onSubmit(disputeTitle, disputeDescription, disputeReason, evidenceImage)
                    presentationMode.wrappedValue.dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color.primaryVariant)
            }
            .padding()
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $evidenceImage)
        }
    }
}
