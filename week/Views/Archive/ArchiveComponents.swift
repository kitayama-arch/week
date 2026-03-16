//
//  ArchiveComponents.swift
//  week
//
//  Created by Codex on 2026/03/16.
//

import SwiftUI
import UIKit

struct ArchiveCapsuleTabBar: View {
    let tabs: [ArchiveTab]
    @Binding var selectedTab: ArchiveTab
    let namespace: Namespace.ID
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(tabs) { tab in
                Button {
                    withAnimation(.snappy(duration: 0.24, extraBounce: 0)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.title)
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .contentShape(Capsule())
                        .background {
                            if selectedTab == tab {
                                Capsule()
                                    .fill(Color.card)
                                    .matchedGeometryEffect(id: "archive-tab-pill", in: namespace)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
            
            Spacer(minLength: 0)
        }
    }
}

struct PickupHeroSection: View {
    let thoughts: [ArchiveThoughtItem]
    let initialThoughtID: String?
    let dailySelectionKey: String
    let onSelectRecord: (WeeklyRecord) -> Void
    
    @State private var displayedThoughtID: String?
    @State private var isRerolling = false
    @State private var rouletteTask: Task<Void, Never>?
    
    init(
        thoughts: [ArchiveThoughtItem],
        initialThoughtID: String?,
        dailySelectionKey: String,
        onSelectRecord: @escaping (WeeklyRecord) -> Void
    ) {
        self.thoughts = thoughts
        self.initialThoughtID = initialThoughtID
        self.dailySelectionKey = dailySelectionKey
        self.onSelectRecord = onSelectRecord
        _displayedThoughtID = State(initialValue: initialThoughtID ?? thoughts.first?.id)
    }
    
    private var displayedThought: ArchiveThoughtItem? {
        if let displayedThoughtID,
           let thought = thoughts.first(where: { $0.id == displayedThoughtID }) {
            return thought
        }
        return thoughts.first
    }
    
    private var thoughtIDsKey: String {
        thoughts.map(\.id).joined(separator: "|")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(
                title: String(localized: "ランダム"),
                subtitle: String(localized: "過去の記録から、今日ひらく一枚を選びます。")
            )
            
            if let displayedThought {
                PickupHeroCard(
                    thought: displayedThought,
                    isRerolling: isRerolling,
                    onTap: {
                        guard !isRerolling else { return }
                        onSelectRecord(displayedThought.weeklyRecord)
                    },
                    onSwipeRight: rerollThought
                )
                .onChange(of: thoughtIDsKey) { _, _ in
                    syncDisplayedThoughtID()
                }
                .onChange(of: dailySelectionKey) { _, _ in
                    syncDisplayedThoughtID(forceReset: true)
                }
                .onDisappear {
                    rouletteTask?.cancel()
                    rouletteTask = nil
                }
            } else {
                ArchiveEmptyStateView(
                    title: String(localized: "まだ『ランダム』はありません"),
                    message: String(localized: "記録が増えると、ここで過去の一枚をひらけるようになります。")
                )
            }
        }
    }
    
    private func syncDisplayedThoughtID(forceReset: Bool = false) {
        guard !thoughts.isEmpty else {
            rouletteTask?.cancel()
            rouletteTask = nil
            isRerolling = false
            displayedThoughtID = nil
            return
        }
        
        if forceReset {
            rouletteTask?.cancel()
            rouletteTask = nil
            isRerolling = false
            displayedThoughtID = initialThoughtID ?? thoughts.first?.id
            return
        }
        
        if let displayedThoughtID,
           thoughts.contains(where: { $0.id == displayedThoughtID }) {
            return
        }
        
        displayedThoughtID = initialThoughtID ?? thoughts.first?.id
    }
    
    private func rerollThought() {
        guard thoughts.count > 1, !isRerolling else { return }
        
        rouletteTask?.cancel()
        rouletteTask = Task { @MainActor in
            isRerolling = true
            
            let selectionFeedback = UISelectionFeedbackGenerator()
            let finishFeedback = UIImpactFeedbackGenerator(style: .soft)
            selectionFeedback.prepare()
            finishFeedback.prepare()
            
            var currentID = displayedThoughtID
            let spinSteps = min(max(thoughts.count, 4), 7)
            let delays: [UInt64] = [45, 65, 90, 120, 160, 210, 270]
            
            for step in 0..<spinSteps {
                guard let nextThought = nextThought(excluding: currentID) else { continue }
                
                withAnimation(.snappy(duration: 0.22, extraBounce: 0.02)) {
                    displayedThoughtID = nextThought.id
                }
                currentID = nextThought.id
                selectionFeedback.selectionChanged()
                
                let delay = delays[min(step, delays.count - 1)] * 1_000_000
                try? await Task.sleep(nanoseconds: delay)
                if Task.isCancelled {
                    isRerolling = false
                    return
                }
            }
            
            finishFeedback.impactOccurred(intensity: 0.55)
            isRerolling = false
            rouletteTask = nil
        }
    }
    
    private func nextThought(excluding currentID: String?) -> ArchiveThoughtItem? {
        let candidates = thoughts.filter { $0.id != currentID }
        return candidates.randomElement() ?? thoughts.first
    }
}

struct ArchiveTopFadeMask: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color.black,
                Color.black,
                Color.black,
                Color.black.opacity(0)
            ]),
            startPoint: .init(x: 0.5, y: 0.1),
            endPoint: .init(x: 0.5, y: 0)
        )
    }
}

struct PickupReflectionSection: View {
    let title: String
    let subtitle: String
    let records: [WeeklyRecord]
    let onSelectRecord: (WeeklyRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if records.isEmpty {
                ArchiveEmptyStateView(
                    title: String(localized: "振り返りはまだありません"),
                    message: String(localized: "週の振り返りを書き始めると、ここから最近のまとめを辿れます。")
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(records) { record in
                        Button {
                            onSelectRecord(record)
                        } label: {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center) {
                                    Text(record.emoji)
                                        .font(.headline)
                                    Text(ArchiveDateFormatter.dayRangeString(
                                        startDate: record.startDate,
                                        endDate: record.endDate
                                    ))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                }
                                
                                Text(record.reflection)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                    .lineLimit(4)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(14)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.card)
                            .cornerRadius(12)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct PickupHeroCard: View {
    let thought: ArchiveThoughtItem
    let isRerolling: Bool
    let onTap: () -> Void
    let onSwipeRight: () -> Void
    
    @GestureState private var dragOffset: CGFloat = 0
    
    var body: some View {
        let swipeGesture = DragGesture(minimumDistance: 16, coordinateSpace: .local)
            .updating($dragOffset) { value, state, _ in
                let horizontal = max(value.translation.width, 0)
                let vertical = abs(value.translation.height)
                if horizontal > vertical {
                    state = min(horizontal, 60)
                }
            }
            .onEnded { value in
                let horizontal = value.translation.width
                let vertical = abs(value.translation.height)
                let predicted = value.predictedEndTranslation.width
                guard horizontal > 52,
                      horizontal > vertical * 1.2 || predicted > 88 else { return }
                onSwipeRight()
            }
        
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.card)
            
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    Text(String(localized: "今日の一枚"))
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundStyle(Color.accentColor)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(Color.accentColor.opacity(0.12))
                        )
                    Spacer()
                    Text(ArchiveDateFormatter.dayString(from: thought.thought.date))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Text(thought.thought.content)
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(5)
                
                HStack(spacing: 8) {
                    Text(thought.weeklyRecord.emoji)
                        .font(.headline)
                    Text(thought.weeklyRecord.goal)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            .id(thought.id)
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: dragOffset * 0.18)
            .opacity(isRerolling ? 0.96 : 1)
            .transition(
                .asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                )
            )
        }
        .contentShape(RoundedRectangle(cornerRadius: 16))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .onTapGesture(perform: onTap)
        .simultaneousGesture(swipeGesture)
        .animation(.snappy(duration: 0.25, extraBounce: 0), value: thought.id)
        .animation(.snappy(duration: 0.2, extraBounce: 0), value: dragOffset)
    }
}

struct PickupWeeklySection: View {
    let title: String
    let subtitle: String
    let records: [WeeklyRecord]
    let onSelectRecord: (WeeklyRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if records.isEmpty {
                ArchiveEmptyStateView(
                    title: String(localized: "まだ十分な記録がありません"),
                    message: String(localized: "週ごとの記録が増えると、動きの多かった週をここで拾えます。")
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(records) { record in
                        WeeklyRecordCardView(weeklyRecord: record)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                onSelectRecord(record)
                            }
                    }
                }
            }
        }
    }
}

struct PickupSectionHeader: View {
    let title: String
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(.headline, design: .rounded))
                .foregroundStyle(.primary)
            if let subtitle, !subtitle.isEmpty {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ArchiveEmptyStateView: View {
    let title: String
    let message: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .cornerRadius(12)
    }
}

struct WeeklyRecordCardView: View {
    let weeklyRecord: WeeklyRecord
    
    private var nonEmptyThoughts: [ThoughtCard] {
        weeklyRecord.thoughts.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(ArchiveDateFormatter.dayRangeString(
                    startDate: weeklyRecord.startDate,
                    endDate: weeklyRecord.endDate
                ))
                .font(.headline)
                .foregroundColor(.primary)
                Spacer()
                Text("\(nonEmptyThoughts.count)")
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
            
            HStack {
                Text(weeklyRecord.emoji)
                    .font(.title2)
                Text(weeklyRecord.goal)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color.card)
        .cornerRadius(10)
    }
}

struct WeeklyRecordDetailView: View {
    let weeklyRecord: WeeklyRecord
    
    private var nonEmptyThoughts: [ThoughtCard] {
        weeklyRecord.thoughts.filter { !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(ArchiveDateFormatter.dayRangeString(
                    startDate: weeklyRecord.startDate,
                    endDate: weeklyRecord.endDate
                ))
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
                        Text("\(nonEmptyThoughts.count)")
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
                    
                    if nonEmptyThoughts.isEmpty {
                        Text("記録はありません")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ThoughtsListView(thoughts: nonEmptyThoughts)
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
}
