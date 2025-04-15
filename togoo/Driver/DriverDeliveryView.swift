//
//  DriverDeliveryView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-13.
//

import SwiftUI
import FirebaseDatabase
import FirebaseAuth
import CoreLocation
import MapKit

struct DriverDeliveryView: View {
    let orderId: String
    @Environment(\.dismiss) var dismiss

    @State private var driverAddress = ""
    @State private var restaurantAddress = ""
    @State private var customerAddress = ""
    @State private var mapRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
                                                      span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @State private var markers: [Marker] = []
    @State private var routeCoordinates: [CLLocationCoordinate2D] = []
    @State private var showMarkArrived = false
    @State private var showMessage = ""
    @State private var navigateToHome = false

    struct Marker: Identifiable {
        let id = UUID()
        let coordinate: CLLocationCoordinate2D
        let color: Color
        let label: String
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button { dismiss() } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                    Text("Driver Map View")
                        .font(.headline)
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding()
                .background(Color.primaryVariant)

                PolylineMapView(
                    region: mapRegion,
                    markers: markers,
                    route: routeCoordinates
                )
                .frame(maxHeight: .infinity)

                if !showMarkArrived {
                    Button("Start The Trip") {
                        drawRoute()
                        showMarkArrived = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryVariant)
                    .padding()
                } else {
                    Button("Mark As Arrived") {
                        markOrderAsDelivered()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color.primaryVariant)
                    .padding()
                }

                if !showMessage.isEmpty {
                    Text(showMessage)
                        .foregroundColor(.red)
                        .padding(.bottom, 6)
                }

                NavigationLink(destination: DriverHomeView(), isActive: $navigateToHome) {
                    EmptyView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .onAppear(perform: fetchAddressesAndSetupMap)
        }
    }

    private func fetchAddressesAndSetupMap() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let driversRef = Database.database().reference().child("driver").child(uid)
        let ordersRef = Database.database().reference().child("orders").child(orderId)

        driversRef.observeSingleEvent(of: .value) { driverSnap in
            driverAddress = driverSnap.childSnapshot(forPath: "address").value as? String ?? ""
            ordersRef.observeSingleEvent(of: .value) { orderSnap in
                restaurantAddress = orderSnap.childSnapshot(forPath: "restaurant/address").value as? String ?? ""
                customerAddress = orderSnap.childSnapshot(forPath: "customer/address").value as? String ?? ""
                drawRoute()
            }
        }
    }

    private func drawRoute() {
        getCoordinates(for: driverAddress) { driverCoord in
            getCoordinates(for: restaurantAddress) { restaurantCoord in
                getCoordinates(for: customerAddress) { customerCoord in
                    if let d = driverCoord, let r = restaurantCoord, let c = customerCoord {
                        markers = [
                            Marker(coordinate: d, color: .blue, label: "Driver (Start)"),
                            Marker(coordinate: r, color: .red, label: "Restaurant (First Stop)"),
                            Marker(coordinate: c, color: .green, label: "Customer (Final Stop)")
                        ]
                        routeCoordinates = [d, r, c]
                        mapRegion = MKCoordinateRegion(center: d, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
                    } else {
                        showMessage = "Failed to get coordinates."
                    }
                }
            }
        }
    }

    private func markOrderAsDelivered() {
        let now = ISO8601DateFormatter().string(from: Date())
        let ref = Database.database().reference().child("orders").child(orderId)
        ref.updateChildValues([
            "status": "delivered",
            "timestamps/delivered": now,
            "estimatedDeliveryTime": ""
        ])
        ref.child("updateLogs").childByAutoId().setValue([
            "timestamp": now,
            "status": "delivered",
            "note": "Status updated to delivered by driver."
        ])
        showMessage = "Order marked as delivered."
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            navigateToHome = true
        }
    }

    private func getCoordinates(for address: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        CLGeocoder().geocodeAddressString(address) { placemarks, _ in
            completion(placemarks?.first?.location?.coordinate)
        }
    }
}

#Preview {
    DriverDeliveryView(orderId: "sample_order_id")
}
