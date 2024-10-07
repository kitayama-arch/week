//
//  ReflectionView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State var weeklyRecord: WeeklyRecord
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
                    GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                    Text("記録")
                        .font(.headline)
                    ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    Text("振り返り")
                        .font(.headline)
                    ReflectionInputView(reflection: $weeklyRecord.reflection)
                    
                    NextGoalCardView(
                        nextWeekGoal: $weeklyRecord.nextWeekGoal,
                        nextWeekEmoji: $weeklyRecord.nextWeekEmoji
                    )
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                Button("振り返りを保存") {
                    weeklyRecord.isReflectionCompleted = true
                    dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
                    dataManager.loadWeeklyRecords()
                    dataManager.loadCurrentWeekRecord()
                    dismiss()
                }
            }
        }
        .navigationTitle("振り返り")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GoalView: View {
    let goal: String
    let emoji: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Text("\(emoji)")
                    .font(.largeTitle)
                Divider()
                    .frame(height: 40)
                Text("\(goal)")
                Spacer()
            }
            .padding(.horizontal)
        }
    }
}

struct ThoughtsListView: View {
    let thoughts: [ThoughtCard]
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(thoughts, id: \.id) { thought in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        HStack {
                            Text(thought.content)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(8)
                            Spacer()
                        }
                    }
                }
            }
        }
        
    }
}

struct ReflectionInputView: View {
    @Binding var reflection: String
    
    var body: some View {
        TextField("振り返りを入力してください", text: $reflection, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

#Preview {
    let sampleDataManager = DataManager.shared
    sampleDataManager.currentWeeklyRecord = WeeklyRecord.sampleData
    return ReflectionView(weeklyRecord: WeeklyRecord.sampleData)
        .environmentObject(sampleDataManager)
}
