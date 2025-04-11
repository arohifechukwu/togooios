//
//  DriverInfoView.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-04-11.
//


import SwiftUI
import FirebaseDatabase

struct DriverInfoView: View {
    var driverId: String
    var eta: String
    
    @State private var driverInfo: [String: String] = [:]
    @State private var isLoading: Bool = true

    var body: some View {
        ScrollView {
            if isLoading {
                VStack {
                    Spacer()
                    ProgressView("Loading driver info...")
                        .padding()
                    Spacer()
                }
            } else {
                VStack(spacing: 12) {
                    if let imageURL = driverInfo["imageURL"],
                       let url = URL(string: imageURL) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.gray
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    }

                    Group {
                        Text("Name: \(driverInfo["name"] ?? "N/A")")
                            .font(.headline)
                        Text("Phone: \(driverInfo["phone"] ?? "N/A")")
                        Text("License Plate: \(driverInfo["licensePlate"] ?? "N/A")")
                        Text("Vehicle: \(driverInfo["carBrand"] ?? "") \(driverInfo["carModel"] ?? "")")
                        Text("ETA: \(eta)")
                    }
                    .font(.subheadline)
                }
                .padding()
            }
        }
        .onAppear(perform: fetchDriverInfo)
    }

    func fetchDriverInfo() {
        let ref = Database.database().reference().child("driver").child(driverId)
        ref.observeSingleEvent(of: .value) { snapshot in
            var info: [String: String] = [:]
            info["name"] = snapshot.childSnapshot(forPath: "name").value as? String
            info["phone"] = snapshot.childSnapshot(forPath: "phone").value as? String
            info["licensePlate"] = snapshot.childSnapshot(forPath: "licensePlate").value as? String
            info["carBrand"] = snapshot.childSnapshot(forPath: "carBrand").value as? String
            info["carModel"] = snapshot.childSnapshot(forPath: "carModel").value as? String
            info["imageURL"] = snapshot.childSnapshot(forPath: "imageURL").value as? String

            DispatchQueue.main.async {
                self.driverInfo = info
                self.isLoading = false
            }
        }
    }
}
