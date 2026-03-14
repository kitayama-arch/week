//
//  ArchiveView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

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

struct ArchiveView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedWeeklyRecord: WeeklyRecord? = nil
    @State private var searchText = ""
    
    private var isSearching: Bool {
        !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var searchResults: [SearchMatchItem] {
        guard isSearching else { return [] }
        let query = searchText.lowercased().trimmingCharacters(in: .whitespaces)
        var items: [SearchMatchItem] = []
        
        for record in dataManager.weeklyRecords.sorted(by: { $0.startDate > $1.startDate }) {
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
                let excerpt = record.reflection
                items.append(SearchMatchItem(
                    id: "reflection-\(record.id)",
                    kind: .reflection,
                    weeklyRecord: record,
                    excerpt: excerpt
                ))
            }
        }
        return items
    }
    
    private var sortedRecords: [WeeklyRecord] {
        dataManager.weeklyRecords.sorted(by: { $0.startDate > $1.startDate })
    }
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("記録・目標・振り返りを検索", text: $searchText)
                            .textFieldStyle(.plain)
                            .autocorrectionDisabled()
                    }
                    .padding(12)
                    .background(Color.card)
                    .cornerRadius(10)
                    .padding(.horizontal)
                    
                    if isSearching {
                        SearchResultsView(
                            results: searchResults,
                            searchQuery: searchText.trimmingCharacters(in: .whitespaces),
                            formatDate: formatDate,
                            onSelect: { selectedWeeklyRecord = $0 }
                        )
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
                                    selectedWeeklyRecord = weeklyRecord
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .navigationBar)
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
            Text("検索結果がありません")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
        } else {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(groupedByKind.enumerated()), id: \.offset) { _, group in
                    let (kind, items) = group
                    VStack(alignment: .leading, spacing: 8) {
                        Text(LocalizedStringKey(kind.sectionTitle))
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
                .foregroundColor(.primary)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .cornerRadius(10)
        .padding(.horizontal, 4)
    }
    
    /// 検索クエリに一致する部分を黄色背景でハイライトしたTextを返す
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
                attributed.foregroundColor = .primary
                let highlightColor = Color(red: 212 / 255, green: 1.0, blue: 0).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85).opacity(0.85)
                var currentIndex = attributed.startIndex

                for segment in segments {
                    let segmentEnd = attributed.index(currentIndex, offsetByCharacters: segment.text.count)
                    if segment.isHighlight {
                        attributed[currentIndex..<segmentEnd].backgroundColor = highlightColor
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
            let range = nsLower.range(of: qLower, options: .caseInsensitive, range: NSRange(location: searchStart, length: nsLower.length - searchStart))
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
    ArchiveView()
}
