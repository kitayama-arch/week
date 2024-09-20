//
//  ReflectionView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI

struct ReflectionView: View {
    @ObservedObject var currentWeeklyRecord: WeeklyRecord
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    GoalView(goal: currentWeeklyRecord.goal)
                    ThoughtsListView(thoughts: currentWeeklyRecord.thoughts)
                    ReflectionInputView(reflection: $currentWeeklyRecord.reflection)
                    NextGoalCardView(nextWeekGoal: $currentWeeklyRecord.nextWeekGoal)
                        .padding(.horizontal)
                    Spacer()
                    Button("保存") {
                        dataManager.updateWeeklyRecord(weeklyRecord: currentWeeklyRecord)
                        dismiss()
                    }
                }
            }
        }
        .navigationTitle("今週の振り返り")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct GoalView: View {
    let goal: String
    
    var body: some View {
        Text("今週の目標:\(goal)")
            .font(.headline)
            .padding()
    }
}

struct ThoughtsListView: View {
    let thoughts: [ThoughtCard]
    
    var body: some View {
        ZStack {
            VStack {
                ForEach(thoughts) { thought in
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white)
                            .frame(height: 60)
                        HStack {
                            Text(thought.content)
                                .background(Color.white)
                                .cornerRadius(8)
                            Spacer()
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.horizontal)
        }
        
    }
}

struct ReflectionInputView: View {
    @Binding var reflection: String
    @State private var textEditorHeight: CGFloat = 50
    
    var body: some View {
        TextEditor(text:$reflection)
            .frame(height: max(50, textEditorHeight))
            .padding(.horizontal )
            .background(Color.white)
            .cornerRadius(8)
            .onChange(of: reflection) { oldValue, newValue in
                withAnimation {
                    updateTextEditorHeight()
                }
            }
            .padding(.horizontal)
    }
    private func updateTextEditorHeight() {
        // 画面幅からパディングを引いたサイズを計算
        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
        // テキストの実際の高さを計算
        let estimatedSize = reflection.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
            context: nil
        )
        
        // 計算された高さと最小高さ(50)を比較し、大きい方を採用
        // 20ピクセルの余白を追加
        textEditorHeight = max(50, estimatedSize.height + 20)
    }
}

#Preview {
    ReflectionView(currentWeeklyRecord: WeeklyRecord.sampleData)
        .environmentObject(DataManager.shared)
}
