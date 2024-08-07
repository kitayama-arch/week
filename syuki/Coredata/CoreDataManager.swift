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
    
    func createThoughtCard(content:String, date:Date, items:[String]) -> ThoughtCardEntity? {
        let context = persistentContainer.viewContext
        let thoughtCardEntity = ThoughtCardEntity(context: context)
        
        thoughtCardEntity.id = UUID()
        thoughtCardEntity.content = content
        thoughtCardEntity.date = date
        thoughtCardEntity.items = items
        
        do {
            try context.save()
            return thoughtCardEntity
        } catch {
            print("ThoughtCardの作成に失敗しました:\(error)")
            return nil
        }
    }
}
