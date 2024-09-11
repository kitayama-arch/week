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
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    // カスタムナビゲーションバー
                    ZStack {
                        if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
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
                            if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
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
                    // DataManager の loadCurrentWeekRecord() を呼び出す
                    dataManager.loadCurrentWeekRecord()
                }
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(isPresented: $showReflectionView) {
                    if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
                        ReflectionView(weeklyRecord: currentWeeklyRecord)
                            .environmentObject(dataManager)
                            .onDisappear { // ReflectionView が消えるときに実行
                                                dataManager.loadCurrentWeekRecord() // currentWeeklyRecord を再読み込み
                                            }
                    }
                }
            }
        }
    }
    
    private func createNewThoughtCard() {
        dataManager.createThoughtCard(content: "", date: Date())
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
    
}

#Preview {
    HomeView()
}
