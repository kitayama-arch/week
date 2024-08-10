//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager()
    
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
                        ForEach(dataManager.thoughtCards.indices, id: \.self) { index in
                            ThoughtCardView(thoughtCard: $dataManager.thoughtCards[index], dataManager: dataManager, index: index)
                        }
                    }
                }
                .onAppear {
                    if dataManager.thoughtCards.isEmpty {
                        dataManager.addSampleThoughtCards()
                    }
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
