//
//  MigrationManager.swift
//  week
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import Foundation
import CoreData
import SwiftData

class MigrationManager {
    private let coreDataManager: CoreDataManager
    private let swiftDataManager: SwiftDataManager
    
    init(coreDataManager: CoreDataManager = CoreDataManager(), swiftDataManager: SwiftDataManager = SwiftDataManager.shared) {
        self.coreDataManager = coreDataManager
        self.swiftDataManager = swiftDataManager
    }
    
    /// CoreDataからSwiftDataへのデータ移行を実行します
    /// - Returns: 移行が成功したかどうか
    func migrateData() -> Bool {
        print("MigrationManager: CoreDataからSwiftDataへのデータ移行を開始します")
        
        // 移行済みかどうかを確認
        if UserDefaults.standard.bool(forKey: "hasCompletedSwiftDataMigration") {
            print("MigrationManager: データ移行は既に完了しています")
            return true
        }
        
        do {
            // WeeklyRecordの移行
            let weeklyRecordMapping = try migrateWeeklyRecords()
            
            // ThoughtCardの移行
            try migrateThoughtCards(weeklyRecordMapping: weeklyRecordMapping)
            
            // 移行完了フラグを設定
            UserDefaults.standard.set(true, forKey: "hasCompletedSwiftDataMigration")
            print("MigrationManager: データ移行が正常に完了しました")
            return true
        } catch {
            print("MigrationManager: データ移行中にエラーが発生しました: \(error)")
            return false
        }
    }
    
    /// CoreDataのWeeklyRecordEntityをSwiftDataに移行します
    /// - Returns: CoreDataのIDとSwiftDataのWeeklyRecordEntityのマッピング
    private func migrateWeeklyRecords() throws -> [UUID: WeeklyRecordEntity] {
        print("MigrationManager: WeeklyRecordの移行を開始します")
        
        let coreDataWeeklyRecords = coreDataManager.readWeeklyRecords()
        var mapping = [UUID: WeeklyRecordEntity]()
        
        for coreDataRecord in coreDataWeeklyRecords {
            guard let id = coreDataRecord.id,
                  let startDate = coreDataRecord.startDate,
                  let endDate = coreDataRecord.endDate,
                  let goal = coreDataRecord.goal,
                  let emoji = coreDataRecord.emoji else {
                print("MigrationManager: WeeklyRecordの必須フィールドが不足しています")
                continue
            }
            
            let swiftDataRecord = WeeklyRecordEntity(
                id: id,
                startDate: startDate,
                endDate: endDate,
                goal: goal,
                emoji: emoji,
                reflection: coreDataRecord.reflection ?? "",
                nextWeekGoal: coreDataRecord.nextWeekGoal ?? "",
                nextWeekEmoji: coreDataRecord.nextWeekEmoji ?? emoji,
                isReflectionCompleted: coreDataRecord.isReflectionCompleted
            )
            
            mapping[id] = swiftDataRecord
            print("MigrationManager: WeeklyRecordを移行しました。ID: \(id.uuidString)")
        }
        
        print("MigrationManager: \(mapping.count)件のWeeklyRecordを移行しました")
        return mapping
    }
    
    /// CoreDataのThoughtCardEntityをSwiftDataに移行します
    /// - Parameter weeklyRecordMapping: CoreDataのIDとSwiftDataのWeeklyRecordEntityのマッピング
    private func migrateThoughtCards(weeklyRecordMapping: [UUID: WeeklyRecordEntity]) throws {
        print("MigrationManager: ThoughtCardの移行を開始します")
        
        let coreDataThoughtCards = coreDataManager.readThoughtCards()
        var migratedCount = 0
        
        for coreDataCard in coreDataThoughtCards {
            guard let id = coreDataCard.id,
                  let content = coreDataCard.content,
                  let date = coreDataCard.date else {
                print("MigrationManager: ThoughtCardの必須フィールドが不足しています")
                continue
            }
            
            let swiftDataCard = ThoughtCardEntity(
                id: id,
                content: content,
                date: date
            )
            
            // WeeklyRecordとの関連付け
            if let coreDataWeeklyRecord = coreDataCard.weeklyRecord,
               let weeklyRecordId = coreDataWeeklyRecord.id,
               let swiftDataWeeklyRecord = weeklyRecordMapping[weeklyRecordId] {
                swiftDataCard.weeklyRecord = swiftDataWeeklyRecord
                if swiftDataWeeklyRecord.thoughts == nil {
                    swiftDataWeeklyRecord.thoughts = []
                }
                swiftDataWeeklyRecord.thoughts?.append(swiftDataCard)
            }
            
            migratedCount += 1
            print("MigrationManager: ThoughtCardを移行しました。ID: \(id.uuidString)")
        }
        
        print("MigrationManager: \(migratedCount)件のThoughtCardを移行しました")
    }
}
