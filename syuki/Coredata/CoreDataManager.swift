//
//  CoreDataManager.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/07.
//

import CoreData

class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "Model") //Core Dataスタックを作成
        persistentContainer.loadPersistentStores { descriptin,error in
            if let error = error{
                fatalError("CoreDataのロードに失敗しました:\(error)")
            }
        }
    }
    
    func createThoughtCard(content:String, date:Date, items:[String]) -> ThoughtCardEntity? { // CoredataManagerではThoughtCardEntityを管理。swiftではThoughtCard
        let context = persistentContainer.viewContext // managedObjectContextを取得
        let thoughtCardEntity = ThoughtCardEntity(context: context)
        
        thoughtCardEntity.id = UUID()
        thoughtCardEntity.content = content
        thoughtCardEntity.date = date
        thoughtCardEntity.items = items
        
        do {
            try context.save()
            print("CoreDataManager: ThoughtCardが正常に保存されました。ID: \(thoughtCardEntity.id?.uuidString ?? "Unknown")")
            return thoughtCardEntity
        } catch {
            print("CoreDataManager: ThoughtCardの作成に失敗しました:\(error)")
            return nil
        }
    }
    
    func readThoughtCards() -> [ThoughtCardEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<ThoughtCardEntity> = ThoughtCardEntity.fetchRequest()
        
        do {
            let thoughtCards = try context.fetch(fetchRequest)
            print("CoreDataManager: 取得したThoughtCardの数: \(thoughtCards.count)")
            return thoughtCards
        } catch {
            print("ThoughtCardの取得に失敗しました:\(error)")
            return []
        }
    }
    
    func updateThoughtCard(thoughtCard: ThoughtCardEntity, newContent: String) {
        let context = persistentContainer.viewContext
        thoughtCard.content = newContent
        
        do {
            try context.save()
            print("CoreDataManager: ThoughtCardが正常に更新されました。ID: \(thoughtCard.id?.uuidString ?? "Unknown")")
        } catch {
            print("CoreDataManager: ThoughtCardの更新に失敗しました: \(error)")
        }
    }
    
    func deleteThoughtCard(thoughtCard: ThoughtCardEntity) {
        let context = persistentContainer.viewContext
        context.delete(thoughtCard)
        
        do {
            try context.save()
        } catch {
            print("ThoughtCardの削除に失敗しました\(error)")
        }
    }
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String, emoji: String) -> WeeklyRecordEntity? {
        let context = persistentContainer.viewContext
        let weeklyRecordEntity = WeeklyRecordEntity(context: context)
        
        weeklyRecordEntity.id = UUID()
        weeklyRecordEntity.startDate = startDate
        weeklyRecordEntity.endDate = endDate
        weeklyRecordEntity.goal = goal
        weeklyRecordEntity.thoughts = []
        weeklyRecordEntity.reflection = ""
        weeklyRecordEntity.nextWeekGoal = ""
        weeklyRecordEntity.emoji = emoji  // 絵文字を保存
        
        do {
            try context.save()
            print("CoreDataManager: WeeklyRecordが正常に作成されました。ID: \(weeklyRecordEntity.id?.uuidString ?? "Unknown")")
            return weeklyRecordEntity
        } catch {
            print("CoreDataManager: WeeklyRecordの作成に失敗しました:\(error)")
            return nil
        }
    }
    
    func readWeeklyRecord(withId id: UUID) -> WeeklyRecordEntity? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("特定のWeeklyRecordの取得に失敗しました: \(error)")
            return nil
        }
    }
    
    func readWeeklyRecords() -> [WeeklyRecordEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
        
        do {
            let weeklyRecords = try context.fetch(fetchRequest)
            print("CoreDataManager: 取得したWeeklyRecordの数: \(weeklyRecords.count)")
            return weeklyRecords
        } catch {
            print("WeeklyRecordの取得に失敗しました:\(error)")
            return []
        }
    }
    
    func updateWeeklyRecord(weeklyRecord: WeeklyRecordEntity, reflection: String, nextWeekGoal: String, emoji: String) {
        let context = persistentContainer.viewContext
        
        weeklyRecord.reflection = reflection
        weeklyRecord.nextWeekGoal = nextWeekGoal
        weeklyRecord.emoji = emoji  // 絵文字を更新
        
        do {
            try context.save()
            print("CoreDataManager: WeeklyRecordが正常に更新されました。ID: \(weeklyRecord.id?.uuidString ?? "Unknown")")
        } catch {
            print("CoreDataManager: WeeklyRecordの更新に失敗しました: \(error)")
        }
    }
    
    func deleteWeeklyRecord(weeklyRecord: WeeklyRecordEntity) {
        let context = persistentContainer.viewContext
        context.delete(weeklyRecord)
        
        do {
            try context.save()
        } catch {
            print("CoreDataManager: WeeklyRecordの削除に失敗しました\(error)")
        }
    }
    func fetchCurrentWeekRecord(for date: Date) -> WeeklyRecordEntity? {
        let calendar = Calendar.current
        let startOfWeek = calendar.startOfDay(for: date)
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        // 日付部分のみを抽出
        let startComponents = calendar.dateComponents([.year, .month, .day], from: startOfWeek)
        let endComponents = calendar.dateComponents([.year, .month, .day], from: endOfWeek)

        // DateComponents を Date に変換
        guard let startDate = calendar.date(from: startComponents),
              let endDate = calendar.date(from: endComponents) else {
            print("Error converting DateComponents to Date")
            return nil
        }

        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
        // Date オブジェクトを比較する条件を設定
        fetchRequest.predicate = NSPredicate(format: "startDate == %@ AND endDate == %@", startDate as NSDate, endDate as NSDate)

        do {
            let weeklyRecords = try persistentContainer.viewContext.fetch(fetchRequest)
            return weeklyRecords.first
        } catch {
            print("Error fetching current week record: \(error)")
        }
        return nil
    }
}
extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        var components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = firstWeekday // 週の始まりを日曜日 (1) に設定
        return self.date(from: components)!
    }
}
