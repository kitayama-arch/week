//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager()
    // ダミーデータを用意
    @State private var thoughtCards = [ThoughtCard(content: "",date: Date(), items: [])] // 初期データとして空のThoughtCardを追加
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    GoalCardView()
                        .padding(.bottom)
                        .padding(.horizontal)
                    
                    ScrollView {
                        ForEach($thoughtCards) { $card in // ForEachで各ThoughtCardをバインディングして渡す
                            ThoughtCardView(thoughtCard: $card, dataManager: dataManager)
                        }
                    }
                }
                .onAppear {
                    dataManager.loadThoughtCards()
                }
                .navigationTitle("今週")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}
#Preview {
    HomeView()
}
