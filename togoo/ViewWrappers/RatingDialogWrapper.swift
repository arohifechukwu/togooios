//
//  RatingDialogWrapper.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct RatingDialogWrapper: View {
    let order: Order?
    let onSubmit: (String, String, String, Float, String) -> Void

    @ViewBuilder var body: some View {
        if let order = order,
           let restaurantId = order.restaurantId,
           let driverId = order.driverId {
            RatingDialogView(
                orderId: order.id,
                restaurantId: restaurantId,
                driverId: driverId,
                onSubmit: onSubmit
            )
        } else {
            VStack {
                Spacer()
                Text("Unable to load rating dialog.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}
