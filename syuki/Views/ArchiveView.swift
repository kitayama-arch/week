//
//  ArchiveView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ArchiveView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedWeeklyRecord: WeeklyRecord? = nil
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            VStack {
                List(dataManager.weeklyRecords.sorted(by: { $0.startDate > $1.startDate })) { weeklyRecord in
                    VStack(alignment: .leading, spacing: 8) {
                        Text("\(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        HStack {
                            Text(weeklyRecord.emoji)
                                .font(.title2)
                            Text(weeklyRecord.goal)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedWeeklyRecord = weeklyRecord
                    }
                    .listRowBackground(Color.card)
                }
                .scrollContentBackground(.hidden)

            }
        }
        .navigationTitle("アーカイブ")
        .sheet(item: $selectedWeeklyRecord) { record in
            WeeklyRecordDetailView(weeklyRecord: record)
        }
        .onAppear {
            if dataManager.weeklyRecords.isEmpty {
                // データがない場合の処理（必要に応じて）
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

struct WeeklyRecordDetailView: View {
    let weeklyRecord: WeeklyRecord
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("\(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                    .font(.system(.headline, design: .rounded))
                    .foregroundColor(.gray)
                    .padding(.vertical)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("目標")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                    GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("記録")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                        Text("\(weeklyRecord.thoughts.count)")
                            .font(.system(.headline, design: .rounded))
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.accentColor.opacity(0.8), Color.accentColor]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .clipShape(Capsule())
                    }
                    .padding(.top)
                    
                    if weeklyRecord.thoughts.isEmpty {
                        Text("記録はありません")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    }
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("振り返り")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    Text(weeklyRecord.reflection)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.card)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("次週の目標")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    GoalView(goal: weeklyRecord.nextWeekGoal, emoji: weeklyRecord.nextWeekEmoji)
                }
            }
            .padding(.horizontal)
        }
        .background(Color.background)
        .navigationTitle("週間記録詳細")
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
}

#Preview {
    ArchiveView()
}
