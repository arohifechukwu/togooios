//
//  MaterialCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-14.
//


import SwiftUI

struct MaterialCardView<Content: View>: View {
    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack {
            content()
                .frame(minHeight: 60) // 👈 Ensures minimum height
                .padding(.horizontal)
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
