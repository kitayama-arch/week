//
//  SwiftDataManager.swift
//  week
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import Foundation
import SwiftData

class SwiftDataManager {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    static let shared = SwiftDataManager()
    
    init() {
        do {
            // CoreDataで使用していたSQLiteファイルのURLを指定して、既存データを引き継ぐ
            let url = URL.applicationSupportDirectory.appendingPathComponent("Model.sqlite")
            let configuration = ModelConfiguration(url: url)
            modelContainer = try ModelContainer(
                for: ThoughtCardEntity.self, WeeklyRecordEntity.self,
                configurations: configuration
            )
            modelContext = modelContainer.mainContext
            print("SwiftDataManager: モデルコンテナを初期化しました")
        } catch {
            fatalError("SwiftDataManager: モデルコンテナの初期化に失敗しました: \(error)")
        }
    }
    
    // MARK: - ThoughtCard操作
    
    func createThoughtCard(content: String, date: Date, weeklyRecord: WeeklyRecordEntity?) -> ThoughtCardEntity {
        let thoughtCard = ThoughtCardEntity(content: content, date: date)
        
        if let weeklyRecord = weeklyRecord {
            thoughtCard.weeklyRecord = weeklyRecord
            if weeklyRecord.thoughts == nil {
                weeklyRecord.thoughts = []
            }
            weeklyRecord.thoughts?.append(thoughtCard)
        }
        
        modelContext.insert(thoughtCard)
        print("SwiftDataManager: ThoughtCardが正常に保存されました。ID: \(thoughtCard.id.uuidString)")
        return thoughtCard
    }
    
    func readThoughtCards() -> [ThoughtCardEntity] {
        do {
            let descriptor = FetchDescriptor<ThoughtCardEntity>()
            let thoughtCards = try modelContext.fetch(descriptor)
            print("SwiftDataManager: 取得したThoughtCardの数: \(thoughtCards.count)")
            return thoughtCards
        } catch {
            print("SwiftDataManager: ThoughtCardの取得に失敗しました: \(error)")
            return []
        }
    }
    
    func updateThoughtCard(thoughtCard: ThoughtCardEntity, newContent: String) {
        thoughtCard.content = newContent
        print("SwiftDataManager: ThoughtCardが正常に更新されました。ID: \(thoughtCard.id.uuidString)")
    }
    
    func deleteThoughtCard(thoughtCard: ThoughtCardEntity) {
        modelContext.delete(thoughtCard)
        print("SwiftDataManager: ThoughtCardが正常に削除されました。ID: \(thoughtCard.id.uuidString)")
    }
    
    // MARK: - WeeklyRecord操作
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String, emoji: String) -> WeeklyRecordEntity {
        let weeklyRecord = WeeklyRecordEntity(
            startDate: startDate,
            endDate: endDate,
            goal: goal,
            emoji: emoji,
            nextWeekEmoji: emoji // 初期値として現在の絵文字を設定
        )
        
        modelContext.insert(weeklyRecord)
        print("SwiftDataManager: WeeklyRecordが正常に作成されました。ID: \(weeklyRecord.id.uuidString)")
        return weeklyRecord
    }
    
    func readWeeklyRecord(withId id: UUID) -> WeeklyRecordEntity? {
        let predicate = #Predicate<WeeklyRecordEntity> { $0.id == id }
        let descriptor = FetchDescriptor<WeeklyRecordEntity>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            return results.first
        } catch {
            print("SwiftDataManager: 特定のWeeklyRecordの取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func readWeeklyRecords() -> [WeeklyRecordEntity] {
        do {
            let descriptor = FetchDescriptor<WeeklyRecordEntity>()
            let weeklyRecords = try modelContext.fetch(descriptor)
            print("SwiftDataManager: 取得したWeeklyRecordの数: \(weeklyRecords.count)")
            return weeklyRecords
        } catch {
            print("SwiftDataManager: WeeklyRecordの取得に失敗しました: \(error)")
            return []
        }
    }
    
    func updateWeeklyRecord(
        weeklyRecord: WeeklyRecordEntity,
        reflection: String,
        nextWeekGoal: String,
        goal: String,
        emoji: String,
        nextWeekEmoji: String,
        isReflectionCompleted: Bool
    ) {
        weeklyRecord.reflection = reflection
        weeklyRecord.nextWeekGoal = nextWeekGoal
        weeklyRecord.goal = goal
        weeklyRecord.emoji = emoji
        weeklyRecord.nextWeekEmoji = nextWeekEmoji
        weeklyRecord.isReflectionCompleted = isReflectionCompleted
        print("SwiftDataManager: WeeklyRecord が正常に更新されました。ID: \(weeklyRecord.id.uuidString)")
    }
    
    func deleteWeeklyRecord(weeklyRecord: WeeklyRecordEntity) {
        modelContext.delete(weeklyRecord)
        print("SwiftDataManager: WeeklyRecordが正常に削除されました")
    }
    
    func fetchCurrentWeekRecord(for date: Date) -> WeeklyRecordEntity? {
        print("SwiftDataManager: fetchCurrentWeekRecord() - date: \(date)")
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 月曜日を週の始まりに設定
        
        // 指定された日付が含まれる週の開始日と終了日を計算
        let weekStart = calendar.startOfWeek(for: date)
        let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? date
        
        // 週の開始日と終了日に基づいて週間記録を検索
        let predicate = #Predicate<WeeklyRecordEntity> {
            $0.startDate <= date && $0.endDate >= date
        }
        
        let descriptor = FetchDescriptor<WeeklyRecordEntity>(predicate: predicate)
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let record = results.first {
                print("SwiftDataManager: 現在の週の記録が見つかりました。ID: \(record.id.uuidString)")
                return record
            } else {
                print("SwiftDataManager: 現在の週の記録が見つかりませんでした。")
                return nil
            }
        } catch {
            print("SwiftDataManager: 現在の週の記録の取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func fetchOrCreateWeeklyRecord(for date: Date) -> WeeklyRecordEntity {
        print("SwiftDataManager: fetchOrCreateWeeklyRecord() - date: \(date)")
        if let existingRecord = fetchCurrentWeekRecord(for: date) {
            return existingRecord
        } else {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // 月曜日を週の始まりに設定
            
            // 指定された日付が含まれる週の開始日と終了日を計算
            let weekStart = calendar.startOfWeek(for: date)
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart) ?? date
            
            // 新しい週間記録を作成
            return createWeeklyRecord(
                startDate: weekStart,
                endDate: weekEnd,
                goal: "",
                emoji: "🌱" // デフォルトの絵文字
            )
        }
    }
    
    func fetchPreviousWeekRecord(before date: Date) -> WeeklyRecordEntity? {
        print("SwiftDataManager: fetchPreviousWeekRecord() - date: \(date)")
        
        // 日付の範囲を設定（現在の日付よりも前の週を対象）
        let predicate = #Predicate<WeeklyRecordEntity> { $0.endDate < date }
        var descriptor = FetchDescriptor<WeeklyRecordEntity>(predicate: predicate)
        descriptor.sortBy = [SortDescriptor(\.endDate, order: .reverse)]
        descriptor.fetchLimit = 1
        
        do {
            let results = try modelContext.fetch(descriptor)
            if let record = results.first {
                print("SwiftDataManager: 前の週の記録が見つかりました。ID: \(record.id.uuidString)")
                return record
            } else {
                print("SwiftDataManager: 前の週の記録が見つかりませんでした。")
                return nil
            }
        } catch {
            print("SwiftDataManager: 前の週のレコードの取得に失敗しました: \(error)")
            return nil
        }
    }
}

// MARK: - Calendar拡張
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let firstDay = self.date(from: components) else {
            return date
        }
        return firstDay
    }
}
