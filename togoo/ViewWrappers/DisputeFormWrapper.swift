//
//  DisputeFormWrapper.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI

struct DisputeFormWrapper: View {
    let order: Order?
    let viewModel: OrderViewModel

    @ViewBuilder
    var body: some View {
        if let order = order {
            DisputeFormView(orderId: order.id) { title, description, reason, image in
                if let image = image {
                    viewModel.uploadEvidence(orderId: order.id,
                                             title: title,
                                             description: description,
                                             reason: reason,
                                             image: image) { url in
                        viewModel.submitDispute(orderId: order.id,
                                                title: title,
                                                description: description,
                                                reason: reason,
                                                imageURL: url)
                    }
                } else {
                    viewModel.submitDispute(orderId: order.id,
                                            title: title,
                                            description: description,
                                            reason: reason,
                                            imageURL: nil)
                }
            }
        } else {
            VStack {
                Spacer()
                Text("Unable to load dispute form.")
                    .foregroundColor(.gray)
                Spacer()
            }
        }
    }
}
