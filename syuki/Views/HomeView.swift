//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    // ダミーデータを用意
    @State private var thoughtCards = [ThoughtCard(content: "",date: Date(), items: [])] // 初期データとして空のThoughtCardを追加
    
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
                        ForEach($thoughtCards) { $card in // ForEachで各ThoughtCardをバインディングして渡す
                            ThoughtCardView(thoughtCard: $card)
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
