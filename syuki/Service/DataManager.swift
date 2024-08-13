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
    
    init() {
        loadThoughtCards()
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
    
    func createWeeklyRecord(startDate: Date, endDate: Date, goal: String) -> WeeklyRecord? {
        guard let entity = coreDataManager.createWeeklyRecord(startDate: startDate, endDate: endDate, goal: goal) else {
            print("DataManager: WeeklyRecordの作成に失敗しました")
            return nil
        }
        guard let id = entity.id,
                let startDate = entity.startDate,
              let endDate = entity.endDate,
              let thoughts = entity.thoughts as? Set<ThoughtCardEntity>,
              let reflection = entity.reflection,
              let goal = entity.goal,
              let nextWeekGoal = entity.nextWeekGoal else {
            print("DataManager: WeeklyRecordの作成に失敗しました: データのアンラップに失敗")
            return nil
        }
        let thoughtCards = thoughts.compactMap { thoughtCardEntity -> ThoughtCard? in
            guard let id = thoughtCardEntity.id,
                    let content = thoughtCardEntity.content,
                  let date = thoughtCardEntity.date,
                  let items = thoughtCardEntity.items else { return nil }
            return ThoughtCard(content: content, date: date, items: items)
        }
        let newWeeklyRecord = WeeklyRecord(
            id: id,
            startDate: startDate,
            endDate: endDate,
            thoughts: thoughtCards,
            reflection: reflection,
            goal: goal,
            nextWeekGoal: nextWeekGoal
            )
        return newWeeklyRecord
    }
}
