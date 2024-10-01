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
            Color.background
                .ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading) {
                    GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                    Text("記録")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    Text("振り返り")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    ReflectionInputView(reflection: $weeklyRecord.reflection)
                    Text("来週の目標")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                        .padding(.top)
                    NextGoalCardView(
                        nextWeekGoal: $weeklyRecord.nextWeekGoal,
                        nextWeekEmoji: $weeklyRecord.nextWeekEmoji
                    )
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
                Button(action: {
                    weeklyRecord.isReflectionCompleted = true
                    dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
                    dataManager.loadWeeklyRecords()
                    dataManager.loadCurrentWeekRecord()
                    dismiss()
                }) {
                    Text("保存")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.95))
                        .padding(.vertical, 12)
                        .padding(.horizontal, 20)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color.accentColor.opacity(0.8),Color.accentColor
                                ]),
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .clipShape(.capsule)
                        .shadow(color: .accent.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                }
                .padding(.vertical)
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
                .fill(Color.card)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            HStack {
                ZStack {
                    Text("\(emoji)")
                        .font(.largeTitle)
                        .blur(radius: 10).opacity(0.5)
                    Text("\(emoji)")
                        .font(.largeTitle)
                }
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1.5, height: 40)
                    .cornerRadius(1)
                
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
                            .fill(Color.card)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        HStack {
                            Text(thought.content)
                                .padding()
                                .background(Color.card)
                                .font(.subheadline)
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
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("どんな一週間でしたか？", text: $reflection, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .padding()
            .background(Color.card)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .focused($isFocused)
    }
}

#Preview {
    let sampleDataManager = DataManager.shared
    sampleDataManager.currentWeeklyRecord = WeeklyRecord.sampleData
    return ReflectionView(weeklyRecord: WeeklyRecord.sampleData)
        .environmentObject(sampleDataManager)
}
