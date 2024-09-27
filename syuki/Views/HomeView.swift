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
    @State private var showArchiveView = false
    @State private var reflectionWeeklyRecord: WeeklyRecord?

    var body: some View {
        NavigationStack {
            ZStack {
                Color.gray.opacity(0.2)
                    .ignoresSafeArea()
                if let currentWeeklyRecord = dataManager.currentWeeklyRecord {
                    // currentWeeklyRecord が存在する場合：通常のコンテンツを表示
                    VStack {
                        // カスタムナビゲーションバー
                        ZStack {
                            Text("\(formatDate(currentWeeklyRecord.startDate)) - \(formatDate(currentWeeklyRecord.endDate))")
                                .font(.headline)
                            HStack {
                                Button {
                                    showArchiveView = true
                                } label: {
                                    Image(systemName: "tray")
                                        .font(.title)
                                }
                                .padding()

                                Spacer()
                                Button(action: {
                                    reflectionWeeklyRecord = currentWeeklyRecord
                                    showReflectionView = true
                                }) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.title)
                                }
                                .padding(.horizontal)
                            }
                        }
                        // 目標カードの表示
                        GoalCardView(weeklyRecord: currentWeeklyRecord)
                            .environmentObject(dataManager)
                        // 思考カードのリスト表示
                        ZStack {
                            ScrollView {
                                ForEach(currentWeeklyRecord.thoughts.indices, id: \.self) { index in
                                    ThoughtCardView(
                                        thoughtCard: $dataManager.thoughtCards[index],
                                        dataManager: dataManager,
                                        index: index
                                    )
                                }
                            }
                            // 新しい思考カードを追加するボタン
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
                } else {
                    // currentWeeklyRecord が nil の場合：振り返り未完了の状態を表示
                    VStack {
                        Spacer()
                        Text("前の週の振り返りがまだ完了していません。")
                            .font(.title)
                            .padding()
                        Button(action: {
                            if let previousWeeklyRecord = dataManager.getPreviousWeeklyRecord() {
                                reflectionWeeklyRecord = previousWeeklyRecord
                                showReflectionView = true
                            }
                        }) {
                            Text("振り返りを行う")
                                .font(.title2)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        Spacer()
                    }
                }
            }
            .onAppear {
                dataManager.loadCurrentWeekRecord()
                print("HomeView appeared - currentWeeklyRecord.thoughts: \(dataManager.currentWeeklyRecord?.thoughts ?? [])")
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showReflectionView) {
                if let reflectionWeeklyRecord = reflectionWeeklyRecord {
                    ReflectionView(currentWeeklyRecord: reflectionWeeklyRecord)
                        .environmentObject(dataManager)
                        .onAppear {
                            dataManager.loadCurrentWeekRecord()
                        }
                        .onDisappear {
                            dataManager.loadCurrentWeekRecord()
                        }
                } else {
                    Text("データがありません")
                }
            }
            .navigationDestination(isPresented: $showArchiveView) {
                ArchiveView()
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
