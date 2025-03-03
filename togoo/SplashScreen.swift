//
//  SplashScreen.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//


import SwiftUI

struct SplashScreen: View {
    @State private var isActive = false

    var body: some View {
        if isActive {
            LoginView() // Navigate to the login screen when isActive is true
        } else {
            VStack {
                Image("logo") // Make sure "logo" is added to your Assets.xcassets
                    .resizable()
                    .frame(width: 250, height: 250)
                Spacer().frame(height: 20)
                Text("Bringing Your Cravings Home!")
                    .font(.system(size: 22, weight: .regular, design: .default))
                    .italic()
                    .foregroundColor(Color.gray.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onAppear {
                // Delay for 4 seconds then change the state to navigate away
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}
