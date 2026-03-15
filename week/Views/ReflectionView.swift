//
//  ReflectionView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI

struct ReflectionView: View {
    @EnvironmentObject var dataManager: DataManager
    @Environment(\.dismiss) private var dismiss
    @State var weeklyRecord: WeeklyRecord
    @State private var selectedTab: ReflectionSheetTab = .reflection
    @State private var sheetPosition: ReflectionSheetPosition = .middle
    @GestureState private var dragTranslation: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let collapsedHeight = max(330, geometry.size.height * 0.42)
            let expandedHeight = min(max(520, geometry.size.height * 0.78), geometry.size.height - 24)
            let currentHeight = resolvedSheetHeight(
                collapsedHeight: collapsedHeight,
                expandedHeight: expandedHeight
            )
            
            ZStack(alignment: .bottom) {
                Color.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        GoalView(goal: weeklyRecord.goal, emoji: weeklyRecord.emoji)
                        HStack {
                            Text("記録")
                                .font(.headline)
                                .foregroundStyle(.secondary)
                            Spacer()
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
                        ThoughtsListView(thoughts: weeklyRecord.thoughts)
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                    .padding(.bottom, collapsedHeight + 40)
                }
                
                ReflectionBottomSheet(
                    selectedTab: $selectedTab,
                    weeklyRecord: $weeklyRecord,
                    onSave: saveReflection
                )
                .frame(maxWidth: .infinity)
                .frame(height: currentHeight, alignment: .top)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .overlay(alignment: .top) {
                    Capsule()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 44, height: 5)
                        .padding(.top, 10)
                }
                .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: -6)
                .gesture(
                    DragGesture(minimumDistance: 10)
                        .updating($dragTranslation) { value, state, _ in
                            state = value.translation.height
                        }
                        .onEnded { value in
                            let projectedHeight = resolvedSheetHeight(
                                collapsedHeight: collapsedHeight,
                                expandedHeight: expandedHeight,
                                translation: value.predictedEndTranslation.height
                            )
                            let midpoint = (collapsedHeight + expandedHeight) / 2
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.86)) {
                                sheetPosition = projectedHeight > midpoint ? .expanded : .middle
                            }
                        }
                )
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: sheetPosition)
                .animation(.spring(response: 0.28, dampingFraction: 0.86), value: dragTranslation)
            }
        }
        .navigationTitle("振り返り")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    private func resolvedSheetHeight(
        collapsedHeight: CGFloat,
        expandedHeight: CGFloat,
        translation: CGFloat? = nil
    ) -> CGFloat {
        let baseHeight = sheetPosition == .middle ? collapsedHeight : expandedHeight
        let drag = translation ?? dragTranslation
        return min(max(baseHeight - drag, collapsedHeight), expandedHeight)
    }
    
    private func saveReflection() {
        weeklyRecord.isReflectionCompleted = true
        dataManager.updateWeeklyRecord(weeklyRecord: weeklyRecord)
        dataManager.loadWeeklyRecords()
        dataManager.loadCurrentWeekRecord()
        dismiss()
    }
}

private enum ReflectionSheetTab: String, CaseIterable, Identifiable {
    case reflection
    case nextGoal
    
    var id: String { rawValue }
    
    var title: LocalizedStringKey {
        switch self {
        case .reflection:
            "振り返り"
        case .nextGoal:
            "来週の目標"
        }
    }
}

private enum ReflectionSheetPosition {
    case middle
    case expanded
}

private struct ReflectionBottomSheet: View {
    @Binding var selectedTab: ReflectionSheetTab
    @Binding var weeklyRecord: WeeklyRecord
    let onSave: () -> Void
    
    private var reflectionCompleted: Bool {
        !weeklyRecord.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var nextGoalCompleted: Bool {
        !weeklyRecord.nextWeekGoal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            ReflectionSheetTabs(
                selectedTab: $selectedTab,
                reflectionCompleted: reflectionCompleted,
                nextGoalCompleted: nextGoalCompleted
            )
            .padding(.top, 26)
            
            Group {
                if selectedTab == .reflection {
                    ReflectionEditorView(reflection: $weeklyRecord.reflection)
                } else {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("来週のテーマや、一番進めたいことを書いておく")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        NextGoalCardView(
                            nextWeekGoal: $weeklyRecord.nextWeekGoal,
                            nextWeekEmoji: $weeklyRecord.nextWeekEmoji
                        )
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            Spacer(minLength: 0)
            
            Button(action: onSave) {
                Text("保存")
                    .font(.title3.bold())
                    .foregroundColor(.white.opacity(0.96))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.accentColor.opacity(0.8), Color.accentColor]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .clipShape(Capsule())
            }
            .shadow(color: .accent.opacity(0.24), radius: 12, x: 0, y: 6)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

private struct ReflectionSheetTabs: View {
    @Binding var selectedTab: ReflectionSheetTab
    let reflectionCompleted: Bool
    let nextGoalCompleted: Bool
    
    var body: some View {
        Picker("振り返り入力", selection: $selectedTab.animation(.spring(response: 0.24, dampingFraction: 0.9))) {
            Text("振り返り")
                .foregroundColor(foregroundColor(for: .reflection, completed: reflectionCompleted))
                .tag(ReflectionSheetTab.reflection)
            
            Text("来週の目標")
                .foregroundColor(foregroundColor(for: .nextGoal, completed: nextGoalCompleted))
                .tag(ReflectionSheetTab.nextGoal)
        }
        .pickerStyle(.segmented)
    }
    
    private func foregroundColor(for tab: ReflectionSheetTab, completed: Bool) -> Color {
        if selectedTab == tab || completed {
            return .accentColor
        }
        return .secondary
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
        VStack(spacing: 10) {
            ForEach(thoughts, id: \.id) { thought in
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.card)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
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

private struct ReflectionEditorView: View {
    @Binding var reflection: String
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("記録を見返しながら、よかったことや気づきを残す")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.card)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.gray.opacity(0.18), lineWidth: 1)
                    )
                
                if reflection.isEmpty {
                    Text("どんな一週間でしたか？")
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
                
                TextEditor(text: $reflection)
                    .scrollContentBackground(.hidden)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                    .frame(minHeight: 180)
                    .focused($isFocused)
            }
        }
    }
}

#Preview {
    let sampleDataManager = DataManager.shared
    let sampleWeeklyRecord = WeeklyRecord(
        id: UUID(),
        startDate: Date(),
        endDate: Date().addingTimeInterval(7*24*60*60),
        thoughts: [
            ThoughtCard(content: "アイデア1", date: Date()),
            ThoughtCard(content: "アイデア2", date: Date())
        ],
        reflection: "",
        goal: "アプリを完成させる",
        nextWeekGoal: "",
        emoji: "😀",
        nextWeekEmoji: "💡"
    )
    sampleDataManager.currentWeeklyRecord = sampleWeeklyRecord
    return ReflectionView(weeklyRecord: sampleWeeklyRecord)
        .environmentObject(sampleDataManager)
}
