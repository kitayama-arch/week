//
//  ArchiveView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ArchiveView: View {
    @ObservedObject private var dataManager = DataManager.shared // 共有インスタンスを使用
    @State private var selectedWeeklyRecord: WeeklyRecord? = nil
    
    var body: some View {
        NavigationView {
            List(dataManager.weeklyRecords.sorted(by: { $0.startDate > $1.startDate })) { weeklyRecord in
                VStack(alignment: .leading) {
                    Text("\(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                        .font(.headline)
                    Text("目標: \(weeklyRecord.goal)")
                        .font(.subheadline)
                }
                .onTapGesture {
                    selectedWeeklyRecord = weeklyRecord
                }
            }
            .navigationTitle("アーカイブ")
            .sheet(item: $selectedWeeklyRecord) { record in
                WeeklyRecordDetailView(weeklyRecord: record)
            }
        }
        .onAppear {
            if dataManager.weeklyRecords.isEmpty {
                //                dataManager.addSampleWeeklyRecords()
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
            VStack(alignment: .leading) {
                
                Text("\(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
                Text("目標")
                    .font(.headline)
                GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                
                Text("記録")
                    .font(.headline)
                if weeklyRecord.thoughts.isEmpty {
                    Text("記録はありません")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ThoughtsListView(thoughts: weeklyRecord.thoughts)
                }
                
                Text("振り返り")
                    .font(.headline)
                Text(weeklyRecord.reflection)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                
                Text("次週の目標")
                    .font(.headline)
                GoalView(goal: weeklyRecord.nextWeekGoal, emoji: weeklyRecord.nextWeekEmoji)
            }
            .padding(.horizontal)
            
        }
        .background(Color.gray.opacity(0.2))
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
