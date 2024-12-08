//
//  SplashScreenView.swift
//  po.ai
//
//  Created by Shinjan Patra on 08/12/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Let’s talk out your problems one at a time.")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                    .padding()

                Spacer()

                NavigationLink(destination: ConversationView()) {
                    Text("Start Now")
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding()
        }
    }
}
