//
//  DriverInfoWrapper.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct DriverInfoWrapper: View {
    let driverId: String?
    let eta: String?

    @ViewBuilder
    var body: some View {
        if let driverId = driverId, let eta = eta {
            DriverInfoView(driverId: driverId, eta: eta)
        } else {
            VStack {
                Spacer()
                Text("Driver information is not available.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}
