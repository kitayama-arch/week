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
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String) -> WeeklyRecordEntity? {
        let context = persistentContainer.viewContext
        let weeklyRecordEntity = WeeklyRecordEntity(context: context)
        
        weeklyRecordEntity.id = UUID()
        weeklyRecordEntity.startDate = startDate
        weeklyRecordEntity.endDate = endDate
        weeklyRecordEntity.goal = goal
        weeklyRecordEntity.thoughts = []
        weeklyRecordEntity.reflection = ""
        weeklyRecordEntity.nextWeekGoal = ""
        
        do {
            try context.save()
            print("CoreDataManager: WeeklyRecordが正常に作成されました。ID: \(weeklyRecordEntity.id?.uuidString ?? "Unknown")")
            return weeklyRecordEntity
        } catch {
            print("CoreDataManager: WeeklyRecordの作成に失敗しました:\(error)")
            return nil
        }
    }
    func readWeeklyRecords() -> [WeeklyRecordEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<WeeklyRecordEntity> = WeeklyRecordEntity.fetchRequest()
        
        do {
            let weeklyRecords = try context.fetch(fetchRequest)
            print("CoreDataManager: 取得したweeklyRecordの数: \(weeklyRecords.count)")
            return weeklyRecords
        } catch {
            print("ThoughtCardの取得に失敗しました:\(error)")
            return []
        }
    }
}
