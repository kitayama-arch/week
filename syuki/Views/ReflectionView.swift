//
//  ReflectionView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI

struct ReflectionView: View {
    @State var weeklyRecord: WeeklyRecord
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            ScrollView {
                VStack {
                    GoalView(goal: weeklyRecord.goal)
                    ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    ReflectionInputView(reflection: $weeklyRecord.reflection)
                    Spacer()
                    Button("保存") {
                        
                    }
                }
                .navigationTitle("今週の振り返り") // ナビゲーションバーのタイトルを設定
                .navigationBarTitleDisplayMode(.inline)
            }
        }
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
    var body: some View {
        TextEditor(text: $reflection)
            .frame(height: 200)
            .cornerRadius(8)
            .padding()
    }
}

#Preview {
    ReflectionView(weeklyRecord: WeeklyRecord.sampleData)
}
