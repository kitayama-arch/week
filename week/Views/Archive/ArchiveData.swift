//
//  ArchiveData.swift
//  week
//
//  Created by Codex on 2026/03/16.
//

import Foundation

enum SearchMatchKind: String {
    case goal
    case thought
    case reflection
    
    var sectionTitle: String {
        switch self {
        case .goal:
            return String(localized: "目標で一致")
        case .thought:
            return String(localized: "記録で一致")
        case .reflection:
            return String(localized: "振り返りで一致")
        }
    }
}

struct SearchMatchItem: Identifiable {
    let id: String
    let kind: SearchMatchKind
    let weeklyRecord: WeeklyRecord
    let excerpt: String
}

enum ArchiveTab: String, CaseIterable, Identifiable {
    case you
    case timeline
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .you:
            return String(localized: "あなた")
        case .timeline:
            return String(localized: "タイムライン")
        }
    }
}

struct ArchiveThoughtItem: Identifiable {
    let id: String
    let thought: ThoughtCard
    let weeklyRecord: WeeklyRecord
}

struct GoalEmojiBubbleItem: Identifiable {
    let id: String
    let emoji: String
    let count: Int
    let lastUsedDate: Date
}

struct ArchiveNormalizedRecord: Identifiable {
    let weeklyRecord: WeeklyRecord
    let goal: String
    let nextWeekGoal: String
    let emoji: String
    let nonEmptyThoughts: [ThoughtCard]
    let completedReflection: String?
    
    var id: UUID { weeklyRecord.id }
    var thoughtCount: Int { nonEmptyThoughts.count }
    
    init(weeklyRecord: WeeklyRecord) {
        self.weeklyRecord = weeklyRecord
        goal = weeklyRecord.goal.archiveTrimmed
        nextWeekGoal = weeklyRecord.nextWeekGoal.archiveTrimmed
        emoji = weeklyRecord.emoji.archiveTrimmed
        nonEmptyThoughts = weeklyRecord.thoughts
            .filter { !$0.content.archiveTrimmed.isEmpty }
            .sorted(by: { $0.date > $1.date })
        let reflection = weeklyRecord.reflection.archiveTrimmed
        completedReflection = reflection.isEmpty ? nil : reflection
    }
}

struct ArchiveDataSnapshot {
    private let normalizedRecords: [ArchiveNormalizedRecord]
    private let currentDayAnchor: Date
    
    init(records: [WeeklyRecord], currentDayAnchor: Date) {
        self.currentDayAnchor = Calendar.current.startOfDay(for: currentDayAnchor)
        normalizedRecords = records
            .sorted(by: { $0.startDate > $1.startDate })
            .map { ArchiveNormalizedRecord(weeklyRecord: $0) }
    }
    
    var sortedRecords: [WeeklyRecord] {
        normalizedRecords.map(\.weeklyRecord)
    }
    
    var archivalThoughtItems: [ArchiveThoughtItem] {
        let pastThoughts = thoughtItems.filter { $0.thought.date < currentDayAnchor }
        return pastThoughts.isEmpty ? thoughtItems : pastThoughts
    }
    
    var randomThought: ArchiveThoughtItem? {
        guard !archivalThoughtItems.isEmpty else { return nil }
        let seed = dailySeed(for: currentDayAnchor)
        return archivalThoughtItems[seed % archivalThoughtItems.count]
    }
    
    var dailySelectionKey: String {
        "\(Int(currentDayAnchor.timeIntervalSince1970))"
    }
    
    var goalEmojiBubbleItems: [GoalEmojiBubbleItem] {
        let grouped = Dictionary(grouping: normalizedRecords, by: \.emoji)
        
        return grouped.compactMap { emoji, records in
            guard !emoji.isEmpty else { return nil }
            let latestRecord = records.max(by: { $0.weeklyRecord.startDate < $1.weeklyRecord.startDate }) ?? records[0]
            return GoalEmojiBubbleItem(
                id: emoji,
                emoji: emoji,
                count: records.count,
                lastUsedDate: latestRecord.weeklyRecord.startDate
            )
        }
        .sorted {
            if $0.count == $1.count {
                return $0.lastUsedDate > $1.lastUsedDate
            }
            return $0.count > $1.count
        }
    }
    
    var recentReflectionRecords: [WeeklyRecord] {
        normalizedRecords.compactMap { record in
            record.completedReflection == nil ? nil : record.weeklyRecord
        }
    }
    
    var mostActiveRecords: [WeeklyRecord] {
        normalizedRecords
            .filter { $0.thoughtCount > 0 }
            .sorted {
                if $0.thoughtCount == $1.thoughtCount {
                    return $0.weeklyRecord.startDate > $1.weeklyRecord.startDate
                }
                return $0.thoughtCount > $1.thoughtCount
            }
            .map(\.weeklyRecord)
    }
    
    func searchResults(matching rawQuery: String) -> [SearchMatchItem] {
        let query = rawQuery.archiveTrimmed.lowercased()
        guard !query.isEmpty else { return [] }
        
        var items: [SearchMatchItem] = []
        
        for record in normalizedRecords {
            let weeklyRecord = record.weeklyRecord
            
            if record.goal.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "goal-\(weeklyRecord.id)",
                    kind: .goal,
                    weeklyRecord: weeklyRecord,
                    excerpt: record.goal
                ))
            }
            
            if record.nextWeekGoal.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "nextGoal-\(weeklyRecord.id)",
                    kind: .goal,
                    weeklyRecord: weeklyRecord,
                    excerpt: record.nextWeekGoal
                ))
            }
            
            for thought in record.nonEmptyThoughts where thought.content.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "thought-\(weeklyRecord.id)-\(thought.id)",
                    kind: .thought,
                    weeklyRecord: weeklyRecord,
                    excerpt: thought.content
                ))
            }
            
            if let reflection = record.completedReflection,
               reflection.lowercased().contains(query) {
                items.append(SearchMatchItem(
                    id: "reflection-\(weeklyRecord.id)",
                    kind: .reflection,
                    weeklyRecord: weeklyRecord,
                    excerpt: reflection
                ))
            }
        }
        
        return items
    }
    
    private var thoughtItems: [ArchiveThoughtItem] {
        normalizedRecords.flatMap { record in
            record.nonEmptyThoughts.map {
                ArchiveThoughtItem(
                    id: "\(record.weeklyRecord.id.uuidString)-\($0.id.uuidString)",
                    thought: $0,
                    weeklyRecord: record.weeklyRecord
                )
            }
        }
        .sorted(by: { $0.thought.date > $1.thought.date })
    }
    
    private func dailySeed(for date: Date) -> Int {
        let calendar = Calendar.current
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: date) ?? 0
        let year = calendar.component(.year, from: date)
        return abs(dayOfYear * 31 + year * 17)
    }
}

enum ArchiveDateFormatter {
    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    static func dayString(from date: Date) -> String {
        dayFormatter.string(from: date)
    }
    
    static func dayRangeString(startDate: Date, endDate: Date) -> String {
        "\(dayString(from: startDate)) - \(dayString(from: endDate))"
    }
}

private extension String {
    var archiveTrimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
