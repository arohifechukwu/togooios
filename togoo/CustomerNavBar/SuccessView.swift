//
//  SuccessView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//

import SwiftUI

struct SuccessView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToHome = false

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // ✅ Custom Back Button
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.primaryVariant)
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top)

                Spacer()

                // ✅ Success Icon
                Image("ic_checkbox")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .padding(.top, 20)

                // ✅ Title
                Text("Payment Confirmed")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundColor(.black)

                // ✅ Subtitle
                Text("Your order has been placed successfully.\nWe'll notify you when it's on the way!")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: "#666666"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .lineSpacing(6)

                // ✅ Continue Shopping Button
                Button(action: {
                    navigateToHome = true
                }) {
                    Text("Continue Shopping")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "F18D34"))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                Spacer()

                NavigationLink(destination: CustomerHomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .padding(24)
            .background(Color.white)
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    SuccessView()
}
