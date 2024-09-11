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
    @Published var currentWeeklyRecord: WeeklyRecord?
    
    static let shared = DataManager()
    
    private init() {
        loadThoughtCards()
        loadWeeklyRecords()
        print("Initial thoughtCards count: \(thoughtCards.count)")
        print("Initial CoreData entities count: \(coreDataManager.readThoughtCards().count)")
        checkCurrentWeekRecord()
    }
    
    func loadThoughtCards() {
        let thoughtCardEntities = coreDataManager.readThoughtCards()
        thoughtCards = thoughtCardEntities.compactMap { entity -> ThoughtCard? in
            guard let id = entity.id,
                  let content = entity.content,
                  let date = entity.date else { return nil }
            return ThoughtCard(
                id: id,
                content: content,
                date: date
            )
        }
    }
    
    func loadWeeklyRecords() {
        weeklyRecords = readWeeklyRecords()
    }
    
    func createThoughtCard(content: String, date: Date) {
        if let entity = coreDataManager.createThoughtCard(content: content, date: date) {
            guard let id = entity.id,
                  let content = entity.content,
                  let date = entity.date
            else {
                print("DataManager: ThoughtCardの作成に失敗しました:データのアンラップに失敗")
                return
            }
            
            let newThoughtCard = ThoughtCard(
                id: id,
                content: content,
                date: date,
                weeklyRecord: getWeeklyRecord(for: date)
            )
            
            if currentWeeklyRecord == nil {
                // 現在の週のWeeklyRecordが存在しない場合、新しく作成
                if let newWeeklyRecord = coreDataManager.fetchOrCreateWeeklyRecord(for: date) {
                    currentWeeklyRecord = toWeeklyRecord(from: newWeeklyRecord)
                    currentWeeklyRecord?.thoughts.append(newThoughtCard)
                    print("DataManager: createThoughtCard() - currentWeeklyRecord.thoughts: \(currentWeeklyRecord?.thoughts ?? [])")
                    // CoreDataの更新
                    do {
                        try coreDataManager.getViewContext().save()
                        print("DataManager: ThoughtCardが正常に作成され、WeeklyRecordに追加されました。ID: \(newThoughtCard.id)")
                        DispatchQueue.main.async {
                            self.thoughtCards.append(newThoughtCard)
                        }
                    } catch {
                        print("DataManager: WeeklyRecordの更新に失敗しました: \(error)")
                    }
                } else {
                    print("DataManager: createThoughtCard() - WeeklyRecordの作成に失敗しました")
                }
            } else if let currentWeeklyRecord = currentWeeklyRecord {
                currentWeeklyRecord.thoughts.append(newThoughtCard)
                do {
                    try coreDataManager.getViewContext().save()
                    print("DataManager: ThoughtCardが正常に作成され、WeeklyRecordに追加されました。ID: \(newThoughtCard.id)")
                    DispatchQueue.main.async {
                        self.thoughtCards.append(newThoughtCard)
                    }
                } catch {
                    print("DataManager: WeeklyRecordの更新に失敗しました: \(error)")
                }
                print("DataManager: createThoughtCard() - currentWeeklyRecord.thoughts: \(currentWeeklyRecord.thoughts)")
            }
            print("Created ThoughtCard details - ID: \(newThoughtCard.id), Content: \(newThoughtCard.content), Date: \(newThoughtCard.date)")
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
        
        
        // 引数で渡された thoughtCard を使って更新
        if let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id }) { // thoughtCards から検索
            
            // thoughtCards の ThoughtCard を更新
            thoughtCards[index].content = newContent
            
            // Core Data の更新
            if let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id }) {
                coreDataManager.updateThoughtCard(thoughtCard: entity, newContent: newContent)
            } else {
                print("DataManager: 更新するThoughtCardのエンティティが見つかりませんでした。ID: \(thoughtCard.id)")
            }
            print("DataManager: ThoughtCardが正常に更新されました。ID: \(thoughtCard.id)")
        } else {
            print("DataManager: 更新するThoughtCardが見つかりませんでした。ID: \(thoughtCard.id)")
        }
    }
    
    func deleteThoughtCard(at offsets: IndexSet) {
        offsets.forEach { Index in
            let thoughtCard = thoughtCards[Index]
            if let currentWeeklyRecord = currentWeeklyRecord,
               let thoughtIndex = currentWeeklyRecord.thoughts.firstIndex(where: { $0.id == thoughtCard.id }) {
                currentWeeklyRecord.thoughts.remove(at: thoughtIndex)
            }
            if let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id }) {
                coreDataManager.deleteThoughtCard(thoughtCard: entity)
            }
        }
        thoughtCards.remove(atOffsets: offsets)
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
                  let date = thoughtCardEntity.date else { return nil }
            return ThoughtCard(
                id: id,
                content: content,
                date: date
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
        
        return weeklyRecordEntites.compactMap { toWeeklyRecord(from: $0) }
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
            print("DataManager: 削除するWeeklyRecord が見つかりませんでした。ID: \(weeklyRecord.id)")
            return
        }
        coreDataManager.deleteWeeklyRecord(weeklyRecord: entity)
    }
    
    func createNextWeeklyRecord(previousWeeklyRecord: WeeklyRecord) -> WeeklyRecord? {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 月曜日を週の始まりに設定
        let startDate = calendar.date(byAdding: .day, value: 7, to: previousWeeklyRecord.endDate)!
        let endDate = calendar.date(byAdding: .day, value: 6, to: startDate)!
        
        guard let newWeeklyRecord = createWeeklyRecord(startDate: startDate, endDate: endDate, goal: previousWeeklyRecord.nextWeekGoal, emoji: previousWeeklyRecord.emoji) else {
            print("DataManager: 次の週のWeeklyRecordの作成に失敗しました")
            return nil
        }
        print("DataManager: 次の週のWeeklyRecordが正常に作成されました。ID: \(newWeeklyRecord.id)")
        return newWeeklyRecord
    }
    
    func loadCurrentWeekRecord() {
        if let weeklyRecordEntity = coreDataManager.fetchCurrentWeekRecord(for: Date()) {
            // WeeklyRecordEntity を WeeklyRecord に変換
            if let currentWeeklyRecord = toWeeklyRecord(from: weeklyRecordEntity) {
                self.currentWeeklyRecord = currentWeeklyRecord
                print("DataManager: loadCurrentWeekRecord() - currentWeeklyRecord: \(currentWeeklyRecord)")
            } else {
                self.currentWeeklyRecord = nil
            }
        } else {
            self.currentWeeklyRecord = nil
        }
    }
    
    // WeeklyRecordEntity を WeeklyRecord に変換する共通関数
    private func toWeeklyRecord(from entity: WeeklyRecordEntity) -> WeeklyRecord? {
        guard let id = entity.id,
              let startDate = entity.startDate,
              let endDate = entity.endDate,
              let thoughts = entity.thoughts as? Set<ThoughtCardEntity>,
              let reflection = entity.reflection,
              let goal = entity.goal,
              let nextWeekGoal = entity.nextWeekGoal,
              let emoji = entity.emoji
        else {
            print("DataManager: WeeklyRecord の変換に失敗しました: データのアンラップに失敗")
            return nil
        }
        
        let thoughtCards = thoughts.compactMap { self.toThoughtCard(from: $0) } // ThoughtCardEntity を ThoughtCard に変換
        
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
    // ThoughtCardEntity を ThoughtCard に変換する関数
    private func toThoughtCard(from entity: ThoughtCardEntity) -> ThoughtCard? {
        guard let id = entity.id,
              let content = entity.content,
              let date = entity.date else {
            print("DataManager: ThoughtCard の変換に失敗しました: データのアンラップに失敗")
            return nil
        }
        
        return ThoughtCard(
            id: id,
            content: content,
            date: date,
            weeklyRecord: getWeeklyRecord(for: date)
        )
    }
    func checkCurrentWeekRecord() {
        if let weeklyRecordEntity = coreDataManager.fetchCurrentWeekRecord(for: Date()) {
            if let currentWeeklyRecord = toWeeklyRecord(from: weeklyRecordEntity) {
                print("現在の週のレコードが見つかりました:")
                print("ID: \(currentWeeklyRecord.id)")
                print("開始日: \(currentWeeklyRecord.startDate)")
                print("終了日: \(currentWeeklyRecord.endDate)")
                print("目標: \(currentWeeklyRecord.goal)")
            } else {
                print("現在の週のレコードの変換に失敗しました")
            }
        } else {
            print("DataManager: checkCurrentWeekRecord_現在の週のレコードが見つかりませんでした")
        }
    }
    private func getWeeklyRecord(for date: Date) -> WeeklyRecord? {
        return weeklyRecords.first { record in
            Calendar.current.isDate(date, inSameDayAs: record.startDate)
        }
    }
}
