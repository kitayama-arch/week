//
//  DataManager.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/10.
//

import Foundation
import CoreData

class DataManager: ObservableObject {
    private let coreDataManager = CoreDataManager() // coredatamanagerのものを使えるように
    
    @Published var thoughtCards:[ThoughtCard] = [] // thoughtcardsが変更されたらswiftUIのview更新
    @Published var weeklyRecords: [WeeklyRecord] = []
    
    init() {
        loadThoughtCards()
        loadWeeklyRecords()
        print("Initial thoughtCards count: \(thoughtCards.count)")
        print("Initial CoreData entities count: \(coreDataManager.readThoughtCards().count)")
    }
    
    func loadThoughtCards() {
        let thoughtCardEntities = coreDataManager.readThoughtCards()
        thoughtCards = thoughtCardEntities.compactMap { entity -> ThoughtCard? in
            guard let id = entity.id, // idを取得
                  let content = entity.content,
                  let date = entity.date,
                  let items = entity.items else { return nil }
            return ThoughtCard(
                id: id,  // idを設定
                content: content,
                date: date,
                items: items
            )
        }
    }
    
    func loadWeeklyRecords() {
        weeklyRecords = readWeeklyRecords()
    }
    
    func createThoughtCard(content: String, date: Date, items: [String]) {
        if let entity = coreDataManager.createThoughtCard(content: content, date: date, items: items) {
            guard let id = entity.id,
                  let content = entity.content,
                  let date = entity.date,
                  let items = entity.items else {
                print("DataManager: ThoughtCardの作成に失敗しました:データのアンラップに失敗")
                return
            }
            
            let newThoughtCard = ThoughtCard(
                id: id,
                content: content,
                date: date,
                items: items
            )
            thoughtCards.append(newThoughtCard)
            print("DataManager: ThoughtCardが正常に作成され、配列に追加されました。ID: \(newThoughtCard.id)")
            print("Created ThoughtCard details - ID: \(newThoughtCard.id), Content: \(newThoughtCard.content), Date: \(newThoughtCard.date), Items: \(newThoughtCard.items)")
        } else {
            print("DataManager: ThoughtCardの作成に失敗しました")
        }
        print("Current thoughtCards count: \(thoughtCards.count)")
        print("Current CoreData entities count: \(coreDataManager.readThoughtCards().count)")
    }
    
    @MainActor
    func updateThoughtCard(thoughtCard: ThoughtCard, newContent: String) {
        print("Updating ThoughtCard with ID: \(thoughtCard.id)")
        print("Current thoughtCards: \(thoughtCards.map { $0.id })")
        print("CoreData entities: \(coreDataManager.readThoughtCards().map { $0.id })")
        guard let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id}),
              let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id}) else {
            print("DataManager: 更新するThoughtCardが見つかりませんでした。ID: \(thoughtCard.id)")
            return
        }
        
        coreDataManager.updateThoughtCard(thoughtCard: entity, newContent: newContent)
        thoughtCards[index].content = newContent
        print("DataManager: ThoughtCardが正常に更新されました。ID: \(thoughtCard.id)")
    }
    
    func deleteThoughtCard(at offsets: IndexSet) {
        offsets.forEach { Index in
            let thoughtCard = thoughtCards[Index]
            if let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id }) {
                coreDataManager.deleteThoughtCard(thoughtCard: entity)
            }
        }
        thoughtCards.remove(atOffsets: offsets)
    }
    
    func addSampleThoughtCards() {
        let sampleCards = [
            (content: "今週の目標を立てる", date: Date(), items: ["仕事の優先順位を決める", "週末の予定を立てる"]),
            (content: "新しいプロジェクトのアイデアを考える", date: Date().addingTimeInterval(86400), items: ["市場調査", "競合分析"]),
            (content: "健康的な生活習慣を始める", date: Date().addingTimeInterval(172800), items: ["毎日30分運動する", "野菜を多く摂取する"])
        ]
        
        for card in sampleCards {
            createThoughtCard(content: card.content, date: card.date, items: card.items)
        }
        
        print("サンプルThoughtCardが追加されました。現在の総数: \(thoughtCards.count)")
    }
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String, emoji: String) -> WeeklyRecord? {
        guard let entity = coreDataManager.createWeeklyRecord(startDate: startDate, endDate: endDate, goal: goal, emoji: emoji) else {
            print("DataManager: WeeklyRecordの作成に失敗しました")
            return nil
        }
        guard let id = entity.id,
              let startDate = entity.startDate,
              let endDate = entity.endDate,
              let thoughts = entity.thoughts as? Set<ThoughtCardEntity>,
              let reflection = entity.reflection,
              let goal = entity.goal,
              let nextWeekGoal = entity.nextWeekGoal,
              let emoji = entity.emoji else {
            print("DataManager: WeeklyRecordの作成に失敗しました: データのアンラップに失敗")
            return nil
        }
        let thoughtCards = thoughts.compactMap { thoughtCardEntity -> ThoughtCard? in
            guard let id = thoughtCardEntity.id,
                  let content = thoughtCardEntity.content,
                  let date = thoughtCardEntity.date,
                  let items = thoughtCardEntity.items else { return nil }
            return ThoughtCard(
                id: id,
                content: content,
                date: date,
                items: items
            )
        }
        let newWeeklyRecord = WeeklyRecord(
            id: id,
            startDate: startDate,
            endDate: endDate,
            thoughts: thoughtCards,
            reflection: reflection,
            goal: goal,
            nextWeekGoal: nextWeekGoal,
            emoji: emoji
        )
        return newWeeklyRecord
    }
    
    func readWeeklyRecords() -> [WeeklyRecord] {
        let weeklyRecordEntites = coreDataManager.readWeeklyRecords()
        
        return weeklyRecordEntites.compactMap { entity -> WeeklyRecord? in
            guard let id = entity.id,
                  let startDate = entity.startDate,
                  let endDate = entity.endDate,
                  let thoughts = entity.thoughts as? Set<ThoughtCardEntity>,
                  let reflection = entity.reflection,
                  let goal = entity.goal,
                  let nextWeekGoal = entity.nextWeekGoal,
                  let emoji = entity.emoji else {
                print("DataManager: WeeklyRecord の読み込みに失敗しました: データのアンラップに失敗")
                return nil
            }
            let thoughtCards = thoughts.compactMap { thoughtCardEntity -> ThoughtCard? in
                guard let id = thoughtCardEntity.id,
                      let content = thoughtCardEntity.content,
                      let date = thoughtCardEntity.date,
                      let items = thoughtCardEntity.items else { return nil }
                return ThoughtCard(
                    id: id,
                    content: content,
                    date: date,
                    items: items
                )
            }
            return WeeklyRecord(
                id: id,
                startDate: startDate,
                endDate: endDate,
                thoughts: thoughtCards,
                reflection: reflection,
                goal: goal,
                nextWeekGoal: nextWeekGoal,
                emoji: emoji
            )
        }
    }
    
    func updateWeeklyRecord(weeklyRecord: WeeklyRecord, reflection: String, nextWeekGoal: String, emoji: String) {
        guard let entity = coreDataManager.readWeeklyRecord(withId: weeklyRecord.id) else {
            print("DataManager: 更新する WeeklyRecord が見つかりませんでした。ID: \(weeklyRecord.id)")
            return
        }
        coreDataManager.updateWeeklyRecord(weeklyRecord: entity, reflection: reflection, nextWeekGoal: nextWeekGoal, emoji: emoji)
    }
    
    func deleteWeeklyRecord(weeklyRecord: WeeklyRecord) {
        guard let entity = coreDataManager.readWeeklyRecord(withId: weeklyRecord.id) else {
            print("DataManager: 削除る WeeklyRecord が見つかりませんでした。ID: \(weeklyRecord.id)")
            return
        }
        coreDataManager.deleteWeeklyRecord(weeklyRecord: entity)
    }
    
    func createNextWeeklyRecord(previousWeeklyRecord: WeeklyRecord) -> WeeklyRecord? {
        let startDate = Calendar.current.date(byAdding: .day, value: 7, to: previousWeeklyRecord.endDate)!
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        
        guard let newWeeklyRecord = createWeeklyRecord(startDate: startDate, endDate: endDate, goal: previousWeeklyRecord.nextWeekGoal, emoji: previousWeeklyRecord.emoji) else {
            print("DataManager: 次の週のWeeklyRecordの成に失敗しました")
            return nil
        }
        
        print("DataManager: 次の週のWeeklyRecordが正常に作成されました。ID: \(newWeeklyRecord.id)")
        return newWeeklyRecord
    }
    
    func addSampleWeeklyRecords() {
        let calendar = Calendar.current
        let today = Date()
        
        // 過去3週間分のサンプルデータを作成
        for i in 0..<3 {
            let endDate = calendar.date(byAdding: .day, value: -7 * i, to: today)!
            let startDate = calendar.date(byAdding: .day, value: -6, to: endDate)!
            
            let goal = "第\(3-i)週目の目標"
            let reflection = "第\(3-i)週目の振り返り"
            let nextWeekGoal = "第\(4-i)週目の目標"
            let emoji = "😀"  // サンプル絵文字
            
            if let weeklyRecord = createWeeklyRecord(startDate: startDate, endDate: endDate, goal: goal, emoji: emoji) {
                weeklyRecord.reflection = reflection
                weeklyRecord.nextWeekGoal = nextWeekGoal
                
                // サンプルの思考カードを追加
                for j in 0..<3 {
                    let thoughtDate = calendar.date(byAdding: .day, value: j, to: startDate)!
                    let thoughtContent = "第\(3-i)週目の思考\(j+1)"
                    let thought = ThoughtCard(id: UUID(), content: thoughtContent, date: thoughtDate, items: [])
                    weeklyRecord.thoughts.append(thought)
                }
                
                weeklyRecords.append(weeklyRecord)
            }
        }
        
        print("サンプルWeeklyRecordが追加されました。現在の総数: \(weeklyRecords.count)")
    }
    
    func getCurrentWeeklyRecord() -> WeeklyRecord? {
//        let calendar = Calendar.current
        let today = Date()
//        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
//        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek)!

        return weeklyRecords.first { record in
            record.startDate <= today && record.endDate >= today
        }
    }

    func saveWeeklyRecord(_ weeklyRecord: WeeklyRecord) {
        if let existingEntity = coreDataManager.readWeeklyRecord(withId: weeklyRecord.id) {
            // 既存のWeeklyRecordを更新
            coreDataManager.updateWeeklyRecord(weeklyRecord: existingEntity,
                                               reflection: weeklyRecord.reflection,
                                               nextWeekGoal: weeklyRecord.nextWeekGoal,
                                               emoji: weeklyRecord.emoji)
            
            // 他のプロパティも更新する必要がある場合
            existingEntity.startDate = weeklyRecord.startDate
            existingEntity.endDate = weeklyRecord.endDate
            existingEntity.goal = weeklyRecord.goal
            
            // Thoughtsの更新（必要に応じて）
            // この部分は複雑になる可能性があるため、別のメソッドとして実装することをお勧めします
        } else {
            // 新しいWeeklyRecordを作成
            _ = coreDataManager.createWeeklyRecord(startDate: weeklyRecord.startDate,
                                                   endDate: weeklyRecord.endDate,
                                                   goal: weeklyRecord.goal,
                                                   emoji: weeklyRecord.emoji)
        }
        
        // メモリ上のweeklyRecords配列を更新
        if let index = weeklyRecords.firstIndex(where: { $0.id == weeklyRecord.id }) {
            weeklyRecords[index] = weeklyRecord
        } else {
            weeklyRecords.append(weeklyRecord)
        }
    }
}
