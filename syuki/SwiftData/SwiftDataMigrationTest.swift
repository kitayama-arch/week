//
//  SwiftDataMigrationTest.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2025/04/12.
//

import Foundation
import SwiftData
import CoreData

/// SwiftDataへの移行をテストするためのクラス
class SwiftDataMigrationTest {
    private let coreDataManager = CoreDataManager()
    private let swiftDataManager = SwiftDataManager.shared
    private let migrationManager = MigrationManager()
    
    /// 移行テストを実行する
    func runTest() -> String {
        var results = [String]()
        
        // ステップ1: CoreDataの現在のデータ数を確認
        let coreDataThoughtCards = coreDataManager.readThoughtCards()
        let coreDataWeeklyRecords = coreDataManager.readWeeklyRecords()
        
        results.append("【テスト開始】")
        results.append("CoreDataの思考カード数: \(coreDataThoughtCards.count)")
        results.append("CoreDataの週間記録数: \(coreDataWeeklyRecords.count)")
        
        // ステップ2: データ移行を実行
        let migrationSuccess = migrationManager.migrateData()
        results.append("データ移行の実行: \(migrationSuccess ? "成功" : "失敗")")
        
        // ステップ3: SwiftDataのデータ数を確認
        let swiftDataThoughtCards = swiftDataManager.readThoughtCards()
        let swiftDataWeeklyRecords = swiftDataManager.readWeeklyRecords()
        
        results.append("SwiftDataの思考カード数: \(swiftDataThoughtCards.count)")
        results.append("SwiftDataの週間記録数: \(swiftDataWeeklyRecords.count)")
        
        // ステップ4: データ数の比較
        let thoughtCardsMatch = coreDataThoughtCards.count == swiftDataThoughtCards.count
        let weeklyRecordsMatch = coreDataWeeklyRecords.count == swiftDataWeeklyRecords.count
        
        results.append("思考カード数の一致: \(thoughtCardsMatch ? "✅" : "❌")")
        results.append("週間記録数の一致: \(weeklyRecordsMatch ? "✅" : "❌")")
        
        // ステップ5: サンプルデータの内容を比較
        if let coreDataCard = coreDataThoughtCards.first, 
           let swiftDataCard = swiftDataThoughtCards.first(where: { $0.id == coreDataCard.id }) {
            results.append("サンプル思考カードの比較:")
            results.append("- CoreData ID: \(coreDataCard.id?.uuidString ?? "nil")")
            results.append("- SwiftData ID: \(swiftDataCard.id.uuidString)")
            
            let contentMatch = coreDataCard.content == swiftDataCard.content
            results.append("- 内容の一致: \(contentMatch ? "✅" : "❌")")
            
            if let coreDataDate = coreDataCard.date {
                let dateMatch = Calendar.current.isDate(coreDataDate, inSameDayAs: swiftDataCard.date)
                results.append("- 日付の一致: \(dateMatch ? "✅" : "❌")")
            }
        }
        
        if let coreDataRecord = coreDataWeeklyRecords.first,
           let swiftDataRecord = swiftDataWeeklyRecords.first(where: { $0.id == coreDataRecord.id }) {
            results.append("サンプル週間記録の比較:")
            results.append("- CoreData ID: \(coreDataRecord.id?.uuidString ?? "nil")")
            results.append("- SwiftData ID: \(swiftDataRecord.id.uuidString)")
            
            let goalMatch = coreDataRecord.goal == swiftDataRecord.goal
            results.append("- 目標の一致: \(goalMatch ? "✅" : "❌")")
            
            let emojiMatch = coreDataRecord.emoji == swiftDataRecord.emoji
            results.append("- 絵文字の一致: \(emojiMatch ? "✅" : "❌")")
            
            if let coreDataThoughts = coreDataRecord.thoughts {
                let coreDataThoughtsCount = coreDataThoughts.count
                let swiftDataThoughtsCount = swiftDataRecord.thoughts?.count ?? 0
                results.append("- 思考カード数: CoreData=\(coreDataThoughtsCount), SwiftData=\(swiftDataThoughtsCount)")
                results.append("- 思考カード数の一致: \(coreDataThoughtsCount == swiftDataThoughtsCount ? "✅" : "❌")")
            }
        }
        
        // ステップ6: 基本的なCRUD操作のテスト
        results.append("基本的なCRUD操作のテスト:")
        
        // 作成テスト
        let testCard = swiftDataManager.createThoughtCard(content: "SwiftDataテスト", date: Date())
        results.append("- 思考カード作成: ✅ (ID: \(testCard.id.uuidString))")
        
        // 読み取りテスト
        let fetchedCards = swiftDataManager.readThoughtCards()
        let fetchSuccess = fetchedCards.contains(where: { $0.id == testCard.id })
        results.append("- 思考カード読み取り: \(fetchSuccess ? "✅" : "❌")")
        
        // 更新テスト
        swiftDataManager.updateThoughtCard(thoughtCard: testCard, newContent: "SwiftDataテスト（更新済み）")
        let updatedCards = swiftDataManager.readThoughtCards()
        let updatedCard = updatedCards.first(where: { $0.id == testCard.id })
        let updateSuccess = updatedCard?.content == "SwiftDataテスト（更新済み）"
        results.append("- 思考カード更新: \(updateSuccess ? "✅" : "❌")")
        
        // 削除テスト
        swiftDataManager.deleteThoughtCard(thoughtCard: testCard)
        let cardsAfterDelete = swiftDataManager.readThoughtCards()
        let deleteSuccess = !cardsAfterDelete.contains(where: { $0.id == testCard.id })
        results.append("- 思考カード削除: \(deleteSuccess ? "✅" : "❌")")
        
        // 週間記録の取得テスト
        let currentDate = Date()
        if let currentWeekRecord = swiftDataManager.fetchCurrentWeekRecord(for: currentDate) {
            results.append("- 現在の週間記録取得: ✅ (ID: \(currentWeekRecord.id.uuidString))")
        } else {
            results.append("- 現在の週間記録取得: ❌")
        }
        
        let weekRecord = swiftDataManager.fetchOrCreateWeeklyRecord(for: currentDate)
        results.append("- 週間記録取得または作成: ✅ (ID: \(weekRecord.id.uuidString))")
        
        if let previousWeekRecord = swiftDataManager.fetchPreviousWeekRecord(before: currentDate) {
            results.append("- 前の週間記録取得: ✅ (ID: \(previousWeekRecord.id.uuidString))")
        } else {
            results.append("- 前の週間記録取得: ❌ (前の週の記録が存在しない可能性があります)")
        }
        
        results.append("【テスト完了】")
        
        // 結果をまとめて返す
        return results.joined(separator: "\n")
    }
}
