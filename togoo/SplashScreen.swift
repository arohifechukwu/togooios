//
//  SplashScreen.swift
//  togoo
//
//  Created by Ifechukwu Aroh on 2025-03-02.
//


import SwiftUI
import FirebaseAuth

struct SplashScreen: View {
    @State private var isActive = false
    @State private var showLogin = false

    var body: some View {
        Group {
            if isActive {
                if showLogin {
                    LoginView()
                } else {
                    // Push authenticated user into LoginView where role check occurs
                    LoginView()
                }
            } else {
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 250, height: 250)
                    Spacer().frame(height: 20)
                    Text("Bringing Your Cravings Home!")
                        .font(.system(size: 22))
                        .italic()
                        .foregroundColor(Color.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                // ✅ Transition to next screen
                if Auth.auth().currentUser != nil {
                    showLogin = false // Authenticated — LoginView will auto-redirect
                } else {
                    showLogin = true // Not logged in — show login form
                }
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}
