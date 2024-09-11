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
            VStack(alignment: .leading, spacing: 20) {
                GoalView(goal: weeklyRecord.goal)
                
                Text("期間: \(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ThoughtsListView(thoughts: weeklyRecord.thoughts)
                
                VStack(alignment: .leading) {
                    Text("振り返り:")
                        .font(.headline)
                    Text(weeklyRecord.reflection)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading) {
                    Text("次週の目標:")
                        .font(.headline)
                    Text(weeklyRecord.nextWeekGoal)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                }
                Spacer()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity,maxHeight: .infinity, alignment: .leading)
            
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
