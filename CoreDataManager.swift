import CoreData

class CoreDataManager {
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Syuki")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String, emoji: String) -> WeeklyRecordEntity {
        let entityDescription = NSEntityDescription.entity(forEntityName: "WeeklyRecordEntity", in: container.viewContext)!
        let weeklyRecord = WeeklyRecordEntity(entity: entityDescription, insertInto: container.viewContext)
        weeklyRecord.startDate = startDate
        weeklyRecord.endDate = endDate
        weeklyRecord.goal = goal
        weeklyRecord.emoji = emoji
        
        do {
            try container.viewContext.save()
        } catch {
            print("WeeklyRecordの保存中にエラーが発生しました: \(error)")
        }
        
        return weeklyRecord
    }
}