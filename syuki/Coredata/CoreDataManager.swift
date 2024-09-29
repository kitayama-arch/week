//
//  CoreDataManager.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/07.
//

import CoreData

class CoreDataManager {
    private let persistentContainer: NSPersistentContainer
    
    // 共有の persistentContainer を追加
    static let sharedPersistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Unable to load persistent stores: \(error)")
            }
        }
        return container
    }()
    
    init(inMemory: Bool = false) {
           // 共有の persistentContainer を使用する
           persistentContainer = CoreDataManager.sharedPersistentContainer
           if inMemory {
               persistentContainer.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
           }
       }
    
    func createThoughtCard(content:String, date:Date, weeklyRecord: WeeklyRecordEntity?) -> ThoughtCardEntity? { // CoredataManagerではThoughtCardEntityを管理。swiftではThoughtCard
        let context = persistentContainer.viewContext // managedObjectContextを取得
        let thoughtCardEntity = ThoughtCardEntity(context: context)
        
        thoughtCardEntity.id = UUID()
        thoughtCardEntity.content = content
        thoughtCardEntity.date = date
        
        if let weeklyRecord = weeklyRecord {
            thoughtCardEntity.weeklyRecord = weeklyRecord
            weeklyRecord.addToThoughts(thoughtCardEntity)
        }
        
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
        weeklyRecordEntity.emoji = emoji
        weeklyRecordEntity.nextWeekEmoji = emoji  // 初期値として現在の絵文字を設定
        
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
    
    func updateWeeklyRecord(
        weeklyRecord: WeeklyRecordEntity,
        reflection: String,
        nextWeekGoal: String,
        goal: String,
        emoji: String,
        nextWeekEmoji: String,
        isReflectionCompleted: Bool
    ) {
        let context = persistentContainer.viewContext
        weeklyRecord.reflection = reflection
        weeklyRecord.nextWeekGoal = nextWeekGoal
        weeklyRecord.goal = goal
        weeklyRecord.emoji = emoji
        weeklyRecord.nextWeekEmoji = nextWeekEmoji
        weeklyRecord.isReflectionCompleted = isReflectionCompleted
        do {
            try context.save()
            print("CoreDataManager: WeeklyRecord が正常に更新されました。ID: \(weeklyRecord.id?.uuidString ?? "Unknown")")
        } catch {
            print("CoreDataManager: WeeklyRecord の更新に失敗しました: \(error)")
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
        print("CoreDataManager: fetchCurrentWeekRecord() - date: \(date)")
        let context = persistentContainer.viewContext
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 月曜日を週の始まりに設定

        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()

        do {
            let weeklyRecords = try context.fetch(fetchRequest)
            print("CoreDataManager: fetchCurrentWeekRecord() - weeklyRecords.count: \(weeklyRecords.count)")
            for record in weeklyRecords {
                if let startDate = record.startDate {
                    if calendar.isDate(date, equalTo: startDate, toGranularity: .weekOfYear) {
                        return record
                    }
                }
            }
        } catch {
            print("Error fetching current week record: \(error)")
        }
        return nil
    }
    
    func getViewContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func fetchOrCreateWeeklyRecord(for date: Date) -> WeeklyRecordEntity? {
        print("CoreDataManager: fetchOrCreateWeeklyRecord() - date: \(date)")
        if let existingRecord = fetchCurrentWeekRecord(for: date) {
            return existingRecord
        } else {
            var calendar = Calendar.current
            calendar.firstWeekday = 2 // 月曜日を週の始まりに設定
            let startOfWeek = calendar.startOfWeek(for: date)
            let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!
            
            return createWeeklyRecord(startDate: startOfWeek, endDate: endOfWeek, goal: "", emoji: "😊")
        }
    }
    func fetchPreviousWeekRecord(before date: Date) -> WeeklyRecordEntity? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
        
        // 日付の範囲を設定（現在の日付よりも前の週を対象）
        fetchRequest.predicate = NSPredicate(format: "endDate < %@", date as NSDate)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "endDate", ascending: false)]
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("CoreDataManager: 前の週のレコードの取得に失敗しました: \(error)")
            return nil
        }
    }
}

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        var components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        components.weekday = 2 // 月曜日を週の始まりに設定 (2は月曜日を表す)
        return self.date(from: components)!
    }
}
