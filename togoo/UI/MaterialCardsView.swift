//
//  MaterialCardsView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-14.
//


import SwiftUI

struct MaterialCardsView<Content: View>: View {
    let content: () -> Content

    var body: some View {
        VStack {
            content()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
        }
        .padding(.horizontal)
    }

    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
}
