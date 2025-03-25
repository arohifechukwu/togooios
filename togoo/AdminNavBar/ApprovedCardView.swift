//
//  ApprovedCardView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-16.
//

import SwiftUI

import SwiftUI

struct ApprovedCardView: View {
    let user: User
    let primaryColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(user.name)
                .font(.headline)
                .foregroundColor(.black)

            Text(user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Text(user.role)
                .font(.subheadline)
                .foregroundColor(.gray)

            Text("Status: \(user.status.isEmpty ? "null" : user.status)")
                .font(.subheadline)
                .italic()
                .foregroundColor(primaryColor)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(primaryColor, lineWidth: 1)
        )
        .shadow(radius: 2)
    }
}


