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
    
    let currentWeeklyRecord: WeeklyRecord?
    init(currentWeeklyRecord: WeeklyRecord? = nil) {
        self.currentWeeklyRecord = currentWeeklyRecord
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                VStack {
                    //                    GoalCardView(weeklyRecord: <#Binding<WeeklyRecord>#>)
                    //                        .padding(.bottom)
                    //                        .padding(.horizontal)
                    
                    ZStack {
                        ScrollView {
                            ForEach(dataManager.thoughtCards.indices, id: \.self) { index in
                                ThoughtCardView(thoughtCard: $dataManager.thoughtCards[index], dataManager: dataManager, index: index)
                            }
                        }
                        if let currentWeeklyRecord = currentWeeklyRecord {
                            VStack(alignment: .leading) {
                                Text("今週の目標: \(currentWeeklyRecord.goal)")
                                    .font(.headline)
                                Text("期間: \(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                    .font(.subheadline)
                                Text("絵文字: \(currentWeeklyRecord.emoji)")
                                // currentWeeklyRecord.thoughts を ThoughtCardView で表示
                                ForEach(currentWeeklyRecord.thoughts.indices, id: \.self) { index in
                                    ThoughtCardView(thoughtCard: $dataManager.thoughtCards[index], dataManager: dataManager, index: index)
                                }
                            }
                            .padding()
                        } else {
                            Text("今週の記録はまだありません")
                                .padding()
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
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) { // 左側に配置
                        if let currentWeeklyRecord = currentWeeklyRecord {
                            Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))") // 期間を表示
                        } else {
                            Text("期間") // データがない場合は「期間」と表示
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(action: {
                            showReflectionView = true
                        }) {
                            Image(systemName: "square.and.pencil")
                        }
                    }
                }
                .navigationDestination(isPresented: $showReflectionView) {
                    ReflectionView(weeklyRecord: WeeklyRecord.sampleData)
                        .environmentObject(dataManager)
                }
            }
        }
    }
    
    private func createNewThoughtCard() {
        dataManager.createThoughtCard(content: "", date: Date(), items: [])
    }
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    HomeView(currentWeeklyRecord: WeeklyRecord.sampleData)
}
