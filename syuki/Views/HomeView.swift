//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    // ダミーデータを用意
    let thoughtCards = sampleThoughtCards
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    Text("今週")
                        .font(.title2).bold()
                        .padding(.horizontal)
                    
                    GoalCardView()
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    ScrollView {
                        ForEach(thoughtCards) { card in
                            ThoughtCardView(thoughtCard: card)
                            // ここではまだ思考カードは1枚のみ
                        }
                    }
                }
            }
        }
    }
}
#Preview {
    HomeView()
}
