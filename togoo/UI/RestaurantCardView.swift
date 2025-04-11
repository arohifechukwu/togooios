import SwiftUI
import CoreLocation

struct RestaurantCardView: View {
    let restaurant: Restaurant
    let fullWidthImage: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ✅ Restaurant Image
            AsyncImage(url: URL(string: restaurant.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(1.4, contentMode: .fill)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: fullWidthImage ? 180 : 140,
                        maxHeight: fullWidthImage ? 220 : 160
                    )
                    .clipped()
                    .cornerRadius(fullWidthImage ? 0 : 12)
            } placeholder: {
                Color.gray
                    .aspectRatio(1.4, contentMode: .fill)
                    .frame(
                        maxWidth: .infinity,
                        minHeight: fullWidthImage ? 180 : 140,
                        maxHeight: fullWidthImage ? 220 : 160
                    )
                    .cornerRadius(fullWidthImage ? 0 : 12)
            }

            // ✅ Restaurant Details
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .foregroundColor(.black)

                Text("\u{2B50} \(String(format: "%.1f", restaurant.rating))")
                    .font(.subheadline)
                    .foregroundColor(Color(hex: "F18D34"))

                Text(restaurant.address)
                    .font(.subheadline)
                    .foregroundColor(.gray)

                HStack {
                    Text("\(restaurant.etaMinutes) mins")
                    Spacer()
                    Text(String(format: "%.1f km", restaurant.distanceKm))
                }
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding(.top, 4)
            .layoutPriority(1)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .onTapGesture {
            onTap()
        }
    }
}
