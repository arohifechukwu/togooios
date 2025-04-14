import SwiftUI
import Stripe
import StripePaymentSheet
import FirebaseDatabase
import FirebaseAuth

struct PaymentView: View {
    @Environment(\.dismiss) var dismiss

    @State private var customerId: String = ""
    @State private var ephemeralKey: String = ""
    @State private var clientSecret: String = ""
    @State private var isPaymentReady = false
    @State private var navigateToSuccess = false

    var cartItems: [CartItem]
    var customer: Customer
    var restaurant: Restaurant
    var checkoutTotal: Double
    var orderNote: String
    var paymentMethod: String = "Card"

    private let baseURL = "https://879c-69-70-47-2.ngrok-free.app"
    private let primaryColor = Color(hex: "F18D34")

    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                
                HStack {
                    Button(action: dismiss.callAsFunction) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(primaryColor)
                    }
                    Spacer()
                    Text("Payment")
                        .font(.headline)
                        .foregroundColor(.black)
                    Spacer()
                    Spacer().frame(width: 60)
                }
                .padding()

                Spacer()

                VStack(spacing: 24) {
                    Button("Credit Card Payment") {
                        presentPaymentSheet()
                    }
                    .disabled(!isPaymentReady)
                    .padding()
                    .frame(width: geo.size.width * 0.8)
                    .background(isPaymentReady ? Color.green : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    Button("Pick Up Order") {
                        storeOrderToFirebase(status: "pickup", transactionId: UUID().uuidString)
                    }
                    .padding()
                    .frame(width: geo.size.width * 0.8)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                Spacer()

                
                NavigationLink(destination: SuccessView(), isActive: $navigateToSuccess) {
                    EmptyView()
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            STPAPIClient.shared.publishableKey = "pk_test_51Pju1z08k0nHIvbw5cvH5RvHpaKxzOJBcNCKKRpkJnXw96nsbEQ3FLKQOUYNVF6w5fff34S2pgn7J3fdzkdEi8Kk003V6xBVlv"
            createCustomer()
        }
    }


    func createCustomer() {
        guard let url = URL(string: "\(baseURL)/create-customer") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let id = json["id"] as? String else {
                print("❌ Failed to create customer")
                return
            }
            self.customerId = id
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                getEphemeralKey()
            }
        }.resume()
    }

    func getEphemeralKey() {
        guard let url = URL(string: "\(baseURL)/create-ephemeral-key") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["customerId": customerId])

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let secret = json["secret"] as? String else {
                print("❌ Failed to fetch ephemeral key")
                return
            }
            self.ephemeralKey = secret
            createPaymentIntent()
        }.resume()
    }

    func createPaymentIntent() {
        guard let url = URL(string: "\(baseURL)/create-payment-intent") else { return }
        let params: [String: Any] = [
            "amount": Int(checkoutTotal * 100),
            "currency": "cad",
            "customerId": customerId
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let secret = json["clientSecret"] as? String else {
                print("❌ Failed to create payment intent")
                return
            }
            self.clientSecret = secret
            self.isPaymentReady = true
        }.resume()
    }

    func presentPaymentSheet() {
        var config = PaymentSheet.Configuration()
        config.merchantDisplayName = "ToGoo Checkout"
        config.customer = .init(id: customerId, ephemeralKeySecret: ephemeralKey)

        let paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret, configuration: config)
        paymentSheet.present(from: UIApplication.shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first?.rootViewController ?? UIViewController()) { result in
                switch result {
                case .completed:
                    print("✅ Payment success")
                    storeOrderToFirebase(status: "succeeded", transactionId: clientSecret)
                case .canceled:
                    print("❌ Payment canceled")
                case .failed(let error):
                    print("❌ Payment failed: \(error.localizedDescription)")
                }
            }
    }

    func storeOrderToFirebase(status: String, transactionId: String) {
        let uid = customer.id
        let ref = Database.database().reference()
        let orderId = ref.child("orders").childByAutoId().key ?? UUID().uuidString

        let placedTime = ISO8601DateFormatter().string(from: Date())
        let placedMillis = Int64(Date().timeIntervalSince1970 * 1000)

        let subtotal = cartItems.reduce(0) { $0 + ($1.foodPrice * Double($1.quantity)) }
        let tips = subtotal * 0.10

        let customerInfo: [String: Any] = [
            "id": uid,
            "name": customer.name,
            "phone": customer.phone,
            "address": customer.address
        ]

        let restaurantInfo: [String: Any] = [
            "id": restaurant.id,
            "name": restaurant.name,
            "address": restaurant.address
        ]

        let paymentInfo: [String: Any] = [
            "subtotalBeforeTax": subtotal,
            "deliveryFare": 5.0,
            "tips": tips,
            "total": checkoutTotal,
            "status": status,
            "transactionId": transactionId,
            "method": paymentMethod
        ]

        let timestamps: [String: Any] = [
            "placed": placedTime,
            "placedMillis": placedMillis,
            "restaurantAccepted": "pending",
            "driverAssigned": "pending",
            "delivered": "pending"
        ]

        let logEntry: [String: Any] = [
            "timestamp": placedTime,
            "status": "placed",
            "note": "Order placed by customer."
        ]

        let orderData: [String: Any] = [
            "customer": customerInfo,
            "restaurant": restaurantInfo,
            "driver": NSNull(),
            "orderDetails": ["items": cartItems.map { $0.toDictionary() }],
            "payment": paymentInfo,
            "status": "placed",
            "timestamps": timestamps,
            "updateLogs": [logEntry],
            "dispute": ["status": "none", "reason": "", "details": ""],
            "notes": orderNote
        ]

        ref.child("orders/\(orderId)").setValue(orderData)
        ref.child("ordersByCustomer/\(uid)/\(orderId)").setValue(true)
        ref.child("ordersByRestaurant/\(restaurant.id)/\(orderId)").setValue(true)

        navigateToSuccess = true
    }
}

#Preview {
    PaymentView(
        cartItems: [
            CartItem(foodId: "Burger", foodDescription: "Juicy", foodImage: "https://...", restaurantId: "res123", foodPrice: 7.99, quantity: 2)
        ],
        customer: Customer(id: "uid1", name: "John Doe", phone: "1234567890", address: "123 Street"),
        restaurant: Restaurant(id: "res123", name: "Testaurant", address: "456 Lane", imageURL: "", location: nil, operatingHours: [:], rating: 4.5, distanceKm: 0, etaMinutes: 0),
        checkoutTotal: 20.50,
        orderNote: "Leave at door."
    )
}
