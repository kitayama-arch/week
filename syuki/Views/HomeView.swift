//
//  ContentView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/01.
//

import SwiftUI
struct HomeView: View {
    @ObservedObject private var dataManager = DataManager.shared // 共有インスタンスを使用
    @State private var showReflectionView = false
    @State private var currentWeeklyRecord: WeeklyRecord?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    // カスタムナビゲーションバー
                    ZStack {
                        if let currentWeeklyRecord = currentWeeklyRecord {
                            Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                .font(.headline)
                        } else {
                            Text("期間")
                                .font(.headline)
                        }
                        HStack {
                            Spacer()
                            Button(action: {
                                showReflectionView = true
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .font(.largeTitle)
                            }
                        }
                    }
                    .padding()
                    
                    ZStack {
                        ScrollView {
                            if let currentWeeklyRecord = currentWeeklyRecord {
                                                           ForEach(currentWeeklyRecord.thoughts.indices, id: \.self) { index in
                                                               ThoughtCardView(thoughtCard: $dataManager.thoughtCards[index], dataManager: dataManager, index: index)
                                                           }
                                                       } else {
                                Text("今週の記録はまだありません")
                                    .padding()
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
                    dataManager.loadCurrentWeekRecord()
                    if let currentWeeklyRecord = currentWeeklyRecord {
                        print("HomeView: onAppear() - currentWeeklyRecord: \(currentWeeklyRecord)")
                    } else {
                        print("HomeView: onAppear() - currentWeeklyRecord is nil")
                    }
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $showReflectionView) {
                    if let currentWeeklyRecord = currentWeeklyRecord {
                        ReflectionView(weeklyRecord: currentWeeklyRecord)
                            .environmentObject(dataManager)
                    }
                }
            }
        }
    }
    
    private func createNewThoughtCard() {
        dataManager.createThoughtCard(content: "", date: Date(), items: [])
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
    private func loadCurrentWeekRecord() {
        dataManager.loadCurrentWeekRecord()
        currentWeeklyRecord = dataManager.weeklyRecords.first
    }
}

#Preview {
    HomeView()
}
