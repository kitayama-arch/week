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
                    
                    ZStack {
                        ScrollView {
                            ForEach(dataManager.thoughtCards.indices, id: \.self) { index in
                                ThoughtCardView(thoughtCard: $dataManager.thoughtCards[index], dataManager: dataManager, index: index)
                            }
                        }
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    createNewThoughtCard()
                                }) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 50))
                                }
                                .padding()
                            }
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
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: ReflectionView(weeklyRecord: WeeklyRecord.sampleData)) {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
            }
        }
    }
    
    private func createNewThoughtCard() {
        dataManager.createThoughtCard(content: "", date: Date(), items: [])
    }
}

#Preview {
    HomeView()
}
