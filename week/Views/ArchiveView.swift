//
//  ArchiveView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI
import UIKit

// 検索一致種別
enum SearchMatchKind: String {
    case goal
    case thought
    case reflection
    
    var sectionTitle: String {
        switch self {
        case .goal: return String(localized: "目標で一致")
        case .thought: return String(localized: "記録で一致")
        case .reflection: return String(localized: "振り返りで一致")
        }
    }
}

// 検索結果1件（何で一致したか + 週 + 該当抜粋）
struct SearchMatchItem: Identifiable {
    let id: String
    let kind: SearchMatchKind
    let weeklyRecord: WeeklyRecord
    let excerpt: String
}

private enum ArchiveTab: String, CaseIterable, Identifiable {
    case you
    case timeline
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .you: return "あなた"
        case .timeline: return "タイムライン"
        }
    }
}

private struct ArchiveThoughtItem: Identifiable {
    let id: String
    let thought: ThoughtCard
    let weeklyRecord: WeeklyRecord
}

private struct GoalEmojiBubbleItem: Identifiable {
    let id: String
    let emoji: String
    let count: Int
    let lastUsedDate: Date
}

struct ArchiveView: View {
    @ObservedObject private var dataManager = DataManager.shared
    let resetToken: Int
    
    @Namespace private var archiveTabNamespace
    @State private var selectedWeeklyRecord: WeeklyRecord? = nil
    @State private var searchText = ""
    @State private var isSearchFieldActive = false
    @State private var selectedTab: ArchiveTab = .you
    @State private var skipNextTabChangeFeedback = false
    
    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var searchResults: [SearchMatchItem] {
        guard isSearching else { return [] }
        let query = searchText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        var items: [SearchMatchItem] = []
        
        for record in sortedRecords {
            if record.goal.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "goal-\(record.id)",
                    kind: .goal,
                    weeklyRecord: record,
                    excerpt: record.goal
                ))
            }
            if record.nextWeekGoal.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "nextGoal-\(record.id)",
                    kind: .goal,
                    weeklyRecord: record,
                    excerpt: record.nextWeekGoal
                ))
            }
            for thought in record.thoughts where thought.content.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "thought-\(record.id)-\(thought.id)",
                    kind: .thought,
                    weeklyRecord: record,
                    excerpt: thought.content
                ))
            }
            if record.reflection.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "reflection-\(record.id)",
                    kind: .reflection,
                    weeklyRecord: record,
                    excerpt: record.reflection
                ))
            }
        }
        return items
    }
    
    private var sortedRecords: [WeeklyRecord] {
        dataManager.weeklyRecords.sorted(by: { $0.startDate > $1.startDate })
    }
    
    private var thoughtItems: [ArchiveThoughtItem] {
        sortedRecords.flatMap { record in
            record.thoughts
                .sorted(by: { $0.date > $1.date })
                .map {
                    ArchiveThoughtItem(
                        id: "\(record.id.uuidString)-\($0.id.uuidString)",
                        thought: $0,
                        weeklyRecord: record
                    )
                }
        }
        .sorted(by: { $0.thought.date > $1.thought.date })
    }
    
    private var archivalThoughtItems: [ArchiveThoughtItem] {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        let pastThoughts = thoughtItems.filter { $0.thought.date < startOfToday }
        return pastThoughts.isEmpty ? thoughtItems : pastThoughts
    }
    
    private var randomThought: ArchiveThoughtItem? {
        guard !archivalThoughtItems.isEmpty else { return nil }
        let seed = dailySeed(for: Date())
        return archivalThoughtItems[seed % archivalThoughtItems.count]
    }
    
    private var goalEmojiBubbleItems: [GoalEmojiBubbleItem] {
        let grouped = Dictionary(grouping: sortedRecords) { record in
            record.emoji.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return grouped.compactMap { emoji, records in
            guard !emoji.isEmpty else { return nil }
            let latestRecord = records.max(by: { $0.startDate < $1.startDate }) ?? records[0]
            return GoalEmojiBubbleItem(
                id: emoji,
                emoji: emoji,
                count: records.count,
                lastUsedDate: latestRecord.startDate
            )
        }
        .sorted {
            if $0.count == $1.count {
                return $0.lastUsedDate > $1.lastUsedDate
            }
            return $0.count > $1.count
        }
    }
    
    private var recentReflectionRecords: [WeeklyRecord] {
        sortedRecords.filter {
            !$0.reflection.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }
    
    private var mostActiveRecords: [WeeklyRecord] {
        sortedRecords
            .filter { !$0.thoughts.isEmpty }
            .sorted {
                if $0.thoughts.count == $1.thoughts.count {
                    return $0.startDate > $1.startDate
                }
                return $0.thoughts.count > $1.thoughts.count
            }
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    dismissSearchKeyboard()
                }
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    NativeSearchBar(
                        text: $searchText,
                        isEditing: $isSearchFieldActive,
                        placeholder: String(localized: "記録・目標・振り返りを検索")
                    )
                    .padding(.horizontal, 8)
                    .padding(.top, 8)
                    
                    ArchiveCapsuleTabBar(
                        tabs: ArchiveTab.allCases,
                        selectedTab: $selectedTab,
                        namespace: archiveTabNamespace
                    )
                    .padding(.top, 12)
                    .padding(.horizontal)
                    .padding(.bottom, 12)
                }
                
                if isSearching {
                    SearchResultsContainerView(
                        results: searchResults,
                        searchQuery: searchText.trimmingCharacters(in: .whitespacesAndNewlines),
                        resetToken: resetToken,
                        formatDate: formatDate,
                        onSelect: { record in
                            dismissSearchKeyboard()
                            selectedWeeklyRecord = record
                        },
                        onBackgroundTap: dismissSearchKeyboard
                    )
                    .padding(.top, 16)
                    .ignoresSafeArea(.container, edges: .bottom)
                } else {
                    TabView(selection: $selectedTab) {
                        YouArchivePage(
                            randomThought: randomThought,
                            goalEmojiBubbleItems: Array(goalEmojiBubbleItems.prefix(8)),
                            recentReflectionRecords: Array(recentReflectionRecords.prefix(3)),
                            mostActiveRecords: Array(mostActiveRecords.prefix(3)),
                            resetToken: resetToken,
                            formatDate: formatDate,
                            onSelectRecord: { selectedWeeklyRecord = $0 },
                            onBackgroundTap: dismissSearchKeyboard
                        )
                        .tag(ArchiveTab.you)
                        
                        TimelineArchivePage(
                            sortedRecords: sortedRecords,
                            resetToken: resetToken,
                            formatDate: formatDate,
                            onSelect: { selectedWeeklyRecord = $0 },
                            onBackgroundTap: dismissSearchKeyboard
                        )
                        .tag(ArchiveTab.timeline)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 12)
                    .ignoresSafeArea(.container, edges: .bottom)
                    .onChange(of: selectedTab) { _, _ in
                        if skipNextTabChangeFeedback {
                            skipNextTabChangeFeedback = false
                        } else {
                            triggerSelectionFeedback()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
        .sheet(item: $selectedWeeklyRecord) { record in
            WeeklyRecordDetailView(weeklyRecord: record)
        }
        .onChange(of: resetToken) { _, _ in
            searchText = ""
            selectedWeeklyRecord = nil
            skipNextTabChangeFeedback = true
            selectedTab = .you
            dismissSearchKeyboard()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }
    
    private func dismissSearchKeyboard() {
        isSearchFieldActive = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func triggerSelectionFeedback() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
    
    private func dailySeed(for date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let year = calendar.component(.year, from: date)
        return abs(dayOfYear * 31 + year * 17)
    }
}

private struct ArchiveCapsuleTabBar: View {
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

private struct TimelineArchivePage: View {
    let sortedRecords: [WeeklyRecord]
    let resetToken: Int
    let formatDate: (Date) -> String
    let onSelect: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "timeline-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    if sortedRecords.isEmpty {
                        ArchiveEmptyStateView(
                            title: "記録はまだありません",
                            message: "記録が増えると、ここに週ごとのアーカイブが並びます。"
                        )
                        .padding(.horizontal)
                        .padding(.top, 12)
                    } else {
                        ContributionGraphView()
                            .padding(.horizontal)
                        
                        LazyVStack(spacing: 8) {
                            ForEach(sortedRecords) { weeklyRecord in
                                WeeklyRecordCardView(
                                    weeklyRecord: weeklyRecord,
                                    formatDate: formatDate
                                )
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    onSelect(weeklyRecord)
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
        }
    }
}

private struct YouArchivePage: View {
    let randomThought: ArchiveThoughtItem?
    let goalEmojiBubbleItems: [GoalEmojiBubbleItem]
    let recentReflectionRecords: [WeeklyRecord]
    let mostActiveRecords: [WeeklyRecord]
    let resetToken: Int
    let formatDate: (Date) -> String
    let onSelectRecord: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "you-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    PickupHeroSection(
                        randomThought: randomThought,
                        formatDate: formatDate,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                    
                    GoalEmojiBubbleSection(
                        title: "今週の絵文字",
                        subtitle: "自分が選びがちな気分やテーマが、だんだん見えてきます。",
                        items: goalEmojiBubbleItems
                    )
                    .padding(.horizontal)
                    
                    PickupReflectionSection(
                        title: "直近の振り返り",
                        subtitle: "最近書いた振り返りをまとめて見返せます。",
                        records: recentReflectionRecords,
                        formatDate: formatDate,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                    
                    PickupWeeklySection(
                        title: "記録が多かった週",
                        subtitle: "思考がよく動いていた週を見つけ直せます。",
                        records: mostActiveRecords,
                        formatDate: formatDate,
                        onSelectRecord: onSelectRecord
                    )
                    .padding(.horizontal)
                }
                .padding(.top, 4)
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
        }
    }
}

private struct PickupHeroSection: View {
    let randomThought: ArchiveThoughtItem?
    let formatDate: (Date) -> String
    let onSelectRecord: (WeeklyRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(
                title: "ランダム",
                subtitle: "過去の記録から、今日ひらく一枚を選びます。"
            )
            
            if let randomThought {
                Button {
                    onSelectRecord(randomThought.weeklyRecord)
                } label: {
                    VStack(alignment: .leading, spacing: 14) {
                        HStack(alignment: .top) {
                            Text("今日の一枚")
                                .font(.system(.caption, design: .rounded, weight: .semibold))
                                .foregroundStyle(Color.accentColor)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.accentColor.opacity(0.12))
                                )
                            Spacer()
                            Text(formatDate(randomThought.thought.date))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(randomThought.thought.content)
                            .font(.system(.body, design: .rounded))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        
                        HStack(spacing: 8) {
                            Text(randomThought.weeklyRecord.emoji)
                                .font(.headline)
                            Text(randomThought.weeklyRecord.goal)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .lineLimit(2)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.card)
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
            } else {
                ArchiveEmptyStateView(
                    title: "まだ『ランダム』はありません",
                    message: "記録が増えると、ここで過去の一枚をひらけるようになります。"
                )
            }
        }
    }
}

private struct GoalEmojiBubbleSection: View {
    let title: String
    let subtitle: String
    let items: [GoalEmojiBubbleItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if items.isEmpty {
                ArchiveEmptyStateView(
                    title: "まだ絵文字の傾向は見えていません",
                    message: "週の目標が増えると、よく選ぶ絵文字がここでふくらんで見えてきます。"
                )
            } else {
                GoalEmojiBubbleCloudView(items: items)
            }
        }
    }
}

private struct GoalEmojiBubbleCloudView: View {
    let items: [GoalEmojiBubbleItem]
    
    var body: some View {
        GeometryReader { geometry in
            let canvasSize = min(geometry.size.width, geometry.size.height)
            let maxCount = items.map(\.count).max() ?? 1
            
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.card)
                
                ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                    let diameter = bubbleDiameter(for: item.count, maxCount: maxCount)
                    let anchor = bubbleAnchor(for: index)
                    let x = diameter / 2 + (canvasSize - diameter) * anchor.x
                    let y = diameter / 2 + (canvasSize - diameter) * anchor.y
                    
                    Text(item.emoji)
                        .font(.system(size: diameter * 0.42))
                        .frame(width: diameter, height: diameter)
                        .background(
                            Circle()
                                .fill(bubbleColor(for: index))
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.32), lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.07), radius: 14, y: 8)
                        .position(x: x, y: y)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
    }
    
    private func bubbleDiameter(for count: Int, maxCount: Int) -> CGFloat {
        let base: CGFloat = 54
        let extra: CGFloat = 54
        guard maxCount > 0 else { return base }
        let ratio = CGFloat(count) / CGFloat(maxCount)
        return base + pow(ratio, 0.82) * extra
    }
    
    private func bubbleAnchor(for index: Int) -> CGPoint {
        let anchors: [CGPoint] = [
            CGPoint(x: 0.5, y: 0.5),
            CGPoint(x: 0.32, y: 0.38),
            CGPoint(x: 0.68, y: 0.36),
            CGPoint(x: 0.35, y: 0.7),
            CGPoint(x: 0.68, y: 0.66),
            CGPoint(x: 0.2, y: 0.56),
            CGPoint(x: 0.8, y: 0.56),
            CGPoint(x: 0.5, y: 0.2),
            CGPoint(x: 0.5, y: 0.82),
            CGPoint(x: 0.2, y: 0.22),
            CGPoint(x: 0.8, y: 0.22),
            CGPoint(x: 0.22, y: 0.82)
        ]
        
        return anchors[index % anchors.count]
    }
    
    private func bubbleColor(for index: Int) -> Color {
        let palette: [Color] = [
            Color.accentColor.opacity(0.2),
            Color.orange.opacity(0.18),
            Color.green.opacity(0.16),
            Color.blue.opacity(0.16)
        ]
        
        return palette[index % palette.count]
    }
}

private struct ArchiveTopFadeMask: View {
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

private struct PickupReflectionSection: View {
    let title: String
    let subtitle: String
    let records: [WeeklyRecord]
    let formatDate: (Date) -> String
    let onSelectRecord: (WeeklyRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if records.isEmpty {
                ArchiveEmptyStateView(
                    title: "振り返りはまだありません",
                    message: "週の振り返りを書き始めると、ここから最近のまとめを辿れます。"
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
                                    Text("\(formatDate(record.startDate)) - \(formatDate(record.endDate))")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("振り返り")
                                        .font(.system(.caption, design: .rounded, weight: .semibold))
                                        .foregroundStyle(Color.accentColor)
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

private struct PickupWeeklySection: View {
    let title: String
    let subtitle: String
    let records: [WeeklyRecord]
    let formatDate: (Date) -> String
    let onSelectRecord: (WeeklyRecord) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if records.isEmpty {
                ArchiveEmptyStateView(
                    title: "まだ十分な記録がありません",
                    message: "週ごとの記録が増えると、動きの多かった週をここで拾えます。"
                )
            } else {
                LazyVStack(spacing: 10) {
                    ForEach(records) { record in
                        WeeklyRecordCardView(
                            weeklyRecord: record,
                            formatDate: formatDate
                        )
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

private struct PickupSectionHeader: View {
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

private struct ArchiveEmptyStateView: View {
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

private struct SearchResultsContainerView: View {
    let results: [SearchMatchItem]
    let searchQuery: String
    let resetToken: Int
    let formatDate: (Date) -> String
    let onSelect: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "search-results-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    SearchResultsView(
                        results: results,
                        searchQuery: searchQuery,
                        formatDate: formatDate,
                        onSelect: onSelect
                    )
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
            .onChange(of: searchQuery) { _, _ in
                proxy.scrollTo(topID, anchor: .top)
            }
        }
    }
}

private struct NativeSearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    let placeholder: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isEditing: $isEditing)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.placeholder = placeholder
        searchBar.searchTextField.autocorrectionType = .no
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchTextField.returnKeyType = .search
        searchBar.searchTextField.enablesReturnKeyAutomatically = false
        searchBar.searchTextField.backgroundColor = .secondarySystemFill
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        if searchBar.text != text {
            searchBar.text = text
        }
        
        if searchBar.placeholder != placeholder {
            searchBar.placeholder = placeholder
        }
        
        if searchBar.showsCancelButton != isEditing {
            searchBar.setShowsCancelButton(isEditing, animated: true)
        }
        
        if !isEditing, searchBar.searchTextField.isFirstResponder {
            searchBar.searchTextField.resignFirstResponder()
        }
    }
    
    final class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool
        
        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isEditing = true
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            isEditing = false
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            dismiss(searchBar)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            dismiss(searchBar)
        }
        
        private func dismiss(_ searchBar: UISearchBar) {
            isEditing = false
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.searchTextField.resignFirstResponder()
        }
    }
}

// 検索結果専用ビュー（目標・記録・振り返りでセクション分け）
struct SearchResultsView: View {
    let results: [SearchMatchItem]
    let searchQuery: String
    let formatDate: (Date) -> String
    let onSelect: (WeeklyRecord) -> Void
    
    private var groupedByKind: [(SearchMatchKind, [SearchMatchItem])] {
        let grouped = Dictionary(grouping: results, by: { $0.kind })
        return [SearchMatchKind.goal, .thought, .reflection].compactMap { kind in
            guard let items = grouped[kind], !items.isEmpty else { return nil }
            return (kind, items)
        }
    }
    
    var body: some View {
        if results.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text("検索結果がありません")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        } else {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(groupedByKind.enumerated()), id: \.offset) { _, group in
                    let (kind, items) = group
                    VStack(alignment: .leading, spacing: 8) {
                        Text(kind.sectionTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                        
                        ForEach(items) { item in
                            SearchResultRowView(
                                item: item,
                                searchQuery: searchQuery,
                                formatDate: formatDate
                            )
                            .onTapGesture {
                                onSelect(item.weeklyRecord)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// 検索結果1行（週の日付 + 該当抜粋、一致部分は黄色ハイライト）
struct SearchResultRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: SearchMatchItem
    let searchQuery: String
    let formatDate: (Date) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("\(formatDate(item.weeklyRecord.startDate)) - \(formatDate(item.weeklyRecord.endDate))")
                .font(.caption)
                .foregroundStyle(.secondary)
            highlightedExcerpt(item.excerpt, query: searchQuery)
                .font(.subheadline)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .cornerRadius(10)
        .padding(.horizontal, 4)
    }
    
    private func highlightedExcerpt(_ text: String, query: String) -> Text {
        let q = query.trimmingCharacters(in: .whitespaces)
        if q.isEmpty {
            return Text(text)
        } else {
            let segments = buildHighlightSegments(text: text, query: q)
            if segments.isEmpty {
                return Text(text)
            } else {
                var attributed = AttributedString(text)
                attributed.foregroundColor = UIColor.label
                let highlightColor = UIColor(
                    red: colorScheme == .dark ? 188 / 255 : 212 / 255,
                    green: colorScheme == .dark ? 225 / 255 : 1.0,
                    blue: 0,
                    alpha: colorScheme == .dark ? 0.72 : 0.85
                )
                var currentIndex = attributed.startIndex
                
                for segment in segments {
                    let segmentEnd = attributed.index(currentIndex, offsetByCharacters: segment.text.count)
                    if segment.isHighlight {
                        attributed[currentIndex..<segmentEnd].backgroundColor = highlightColor
                        attributed[currentIndex..<segmentEnd].foregroundColor = UIColor.label
                    }
                    currentIndex = segmentEnd
                }
                return Text(attributed)
            }
        }
    }
    
    private func buildHighlightSegments(text: String, query: String) -> [(isHighlight: Bool, text: String)] {
        let nsText = text as NSString
        let nsLower = text.lowercased() as NSString
        let qLower = query.lowercased()
        var segments: [(isHighlight: Bool, text: String)] = []
        var searchStart = 0
        
        while searchStart < nsLower.length {
            let range = nsLower.range(
                of: qLower,
                options: .caseInsensitive,
                range: NSRange(location: searchStart, length: nsLower.length - searchStart)
            )
            if range.location == NSNotFound { break }
            if searchStart < range.location {
                segments.append((false, nsText.substring(with: NSRange(location: searchStart, length: range.location - searchStart))))
            }
            segments.append((true, nsText.substring(with: range)))
            searchStart = range.location + range.length
        }
        
        if searchStart < nsText.length {
            segments.append((false, nsText.substring(from: searchStart)))
        }
        return segments
    }
}

// 週カード（検索時以外の一覧用）
struct WeeklyRecordCardView: View {
    let weeklyRecord: WeeklyRecord
    let formatDate: (Date) -> String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(formatDate(weeklyRecord.startDate)) - \(formatDate(weeklyRecord.endDate))")
                    .font(.headline)
                    .foregroundColor(.primary)
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
    ArchiveView(resetToken: 0)
}
