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
        loadCurrentWeekRecord()
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
    
    // 修正1: ThoughtCardEntityとWeeklyRecordEntityの関連付け
    func createThoughtCard(content: String, date: Date) {
        // 現在のWeeklyRecordEntityを取得
        var weeklyRecordEntity: WeeklyRecordEntity?
        if let currentWeeklyRecord = currentWeeklyRecord {
            weeklyRecordEntity = coreDataManager.readWeeklyRecord(withId: currentWeeklyRecord.id)
        } else {
            // 存在しない場合は新規作成
            if let newWeeklyRecordEntity = coreDataManager.fetchOrCreateWeeklyRecord(for: date) {
                currentWeeklyRecord = toWeeklyRecord(from: newWeeklyRecordEntity)
                weeklyRecordEntity = newWeeklyRecordEntity
            } else {
                print("DataManager: createThoughtCard() - WeeklyRecordの作成に失敗しました")
                return
            }
        }
        
        // ThoughtCardEntityの作成と関連付け
        if let entity = coreDataManager.createThoughtCard(content: content, date: date, weeklyRecord: weeklyRecordEntity) {
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
            
            // currentWeeklyRecordのthoughtsに追加
            currentWeeklyRecord?.thoughts.append(newThoughtCard)
            
            // SwiftUIのビューを更新
            DispatchQueue.main.async {
                self.thoughtCards.append(newThoughtCard)
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
    
    func deleteThoughtCard(thoughtCard: ThoughtCard) {
        // Core Data から削除
        if let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id }) {
            coreDataManager.deleteThoughtCard(thoughtCard: entity)
        }
        
        // currentWeeklyRecord の thoughts から削除
        if let index = currentWeeklyRecord?.thoughts.firstIndex(where: { $0.id == thoughtCard.id }) {
            currentWeeklyRecord?.thoughts.remove(at: index)
        }
        
        // 必要に応じて thoughtCards 配列からも削除
        if let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id }) {
            thoughtCards.remove(at: index)
        }
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
              let emoji = entity.emoji,
              let nextWeekEmoji = entity.nextWeekEmoji else {
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
            emoji: emoji,
            nextWeekEmoji: nextWeekEmoji
        )
        return newWeeklyRecord
    }
    
    func readWeeklyRecords() -> [WeeklyRecord] {
        let weeklyRecordEntites = coreDataManager.readWeeklyRecords()
        
        return weeklyRecordEntites.compactMap { toWeeklyRecord(from: $0) }
    }
    
    func updateWeeklyRecord(weeklyRecord: WeeklyRecord) {
        guard let entity = coreDataManager.readWeeklyRecord(withId: weeklyRecord.id) else {
            print("DataManager: 更新する WeeklyRecord が見つかりませんでした。ID: \(weeklyRecord.id)")
            return
        }
        coreDataManager.updateWeeklyRecord(
            weeklyRecord: entity,
            reflection: weeklyRecord.reflection,
            nextWeekGoal: weeklyRecord.nextWeekGoal,
            goal: weeklyRecord.goal,
            emoji: weeklyRecord.emoji,
            nextWeekEmoji: weeklyRecord.nextWeekEmoji,
            isReflectionCompleted: weeklyRecord.isReflectionCompleted
        )
        print("DataManager: WeeklyRecord が正常に更新されました。ID: \(weeklyRecord.id)")
        print("DataManager: updateWeeklyRecord() - reflection: \(weeklyRecord.reflection)") // 振り返り内容
        print("DataManager: updateWeeklyRecord() - nextWeekGoal: \(weeklyRecord.nextWeekGoal)") // 次週の目標
    }
    
    func deleteWeeklyRecord(weeklyRecord: WeeklyRecord) {
        guard let entity = coreDataManager.readWeeklyRecord(withId: weeklyRecord.id) else {
            print("DataManager: 削除するWeeklyRecord が見つかりませんでした。ID: \(weeklyRecord.id)")
            return
        }
        coreDataManager.deleteWeeklyRecord(weeklyRecord: entity)
        print("DataManager: WeeklyRecord が正常に削除されました。ID: \(weeklyRecord.id)") // デバッグログを追加
    }
    
    func createNextWeeklyRecord(previousWeeklyRecord: WeeklyRecord) -> WeeklyRecord? {
        let startDate = getStartOfWeek(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
        
        guard let newWeeklyRecord = createWeeklyRecord(
            startDate: startDate,
            endDate: endDate,
            goal: previousWeeklyRecord.nextWeekGoal,
            emoji: previousWeeklyRecord.nextWeekEmoji
        ) else {
            print("DataManager: 次の週の WeeklyRecord の作成に失敗しました")
            return nil
        }
        print("DataManager: 次の週の WeeklyRecord が正常に作成されました。ID: \(newWeeklyRecord.id)")
        return newWeeklyRecord
    }
    
    
    func loadCurrentWeekRecord() {
        if let weeklyRecordEntity = coreDataManager.fetchCurrentWeekRecord(for: Date()) {
            // パターン4, 5: 現在の週の WeeklyRecord が存在する場合
            if let newWeeklyRecord = toWeeklyRecord(from: weeklyRecordEntity) {
                if let currentWeeklyRecord = self.currentWeeklyRecord {
                    currentWeeklyRecord.update(from: newWeeklyRecord)
                } else {
                    self.currentWeeklyRecord = newWeeklyRecord
                }
                print("DataManager: loadCurrentWeekRecord() - currentWeeklyRecord: \(String(describing: self.currentWeeklyRecord))")
            } else {
                self.currentWeeklyRecord = nil
            }
        } else {
            // 現在の週の WeeklyRecord が存在しない場合
            if let previousWeeklyRecordEntity = coreDataManager.fetchPreviousWeekRecord(before: Date()),
               let previousWeeklyRecord = toWeeklyRecord(from: previousWeeklyRecordEntity) {
                if previousWeeklyRecord.isReflectionCompleted {
                    // パターン2: 前の週の振り返りが完了している場合、新しい WeeklyRecord を作成
                    if let newWeeklyRecord = createNextWeeklyRecord(previousWeeklyRecord: previousWeeklyRecord) {
                        self.currentWeeklyRecord = newWeeklyRecord
                        print("DataManager: 新しい週の WeeklyRecord を作成しました: \(String(describing: self.currentWeeklyRecord))")
                    } else {
                        self.currentWeeklyRecord = nil
                        print("DataManager: 新しい WeeklyRecord の作成に失敗しました")
                    }
                } else {
                    // パターン3: 前の週の振り返りが未完了の場合、currentWeeklyRecord を nil に設定
                    self.currentWeeklyRecord = nil
                    print("DataManager: 前の週の振り返りが未完了のため、currentWeeklyRecord は nil です")
                }
            } else {
                // パターン1: 前の週の WeeklyRecord が存在しない場合、デフォルトの WeeklyRecord を作成
                let startDate = getStartOfWeek(for: Date())
                let endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate)!
                let defaultGoal = ""
                let defaultEmoji = "😊"
                if let newWeeklyRecord = createWeeklyRecord(startDate: startDate, endDate: endDate, goal: defaultGoal, emoji: defaultEmoji) {
                    self.currentWeeklyRecord = newWeeklyRecord
                    print("DataManager: デフォルトの値で新しい WeeklyRecord を作成しました: \(String(describing: self.currentWeeklyRecord))")
                } else {
                    self.currentWeeklyRecord = nil
                    print("DataManager: 新しい WeeklyRecord の作成に失敗しました")
                }
            }
        }
    }
    
    
    
    private func toWeeklyRecord(from entity: WeeklyRecordEntity) -> WeeklyRecord? {
        guard let id = entity.id,
              let startDate = entity.startDate,
              let endDate = entity.endDate,
              let goal = entity.goal,
              let emoji = entity.emoji else {
            print("DataManager: WeeklyRecord の変換に失敗しました: データのアンラップに失敗")
            return nil
        }
        let reflection = entity.reflection ?? ""
        let nextWeekGoal = entity.nextWeekGoal ?? ""
        let nextWeekEmoji = entity.nextWeekEmoji ?? ""
        let isReflectionCompleted = entity.isReflectionCompleted
        let thoughtsSet = entity.thoughts as? Set<ThoughtCardEntity> ?? []
        let thoughtCards = thoughtsSet.compactMap { self.toThoughtCard(from: $0) }
            .sorted(by: { $0.date < $1.date })
        return WeeklyRecord(
            id: id,
            startDate: startDate,
            endDate: endDate,
            thoughts: thoughtCards,
            reflection: reflection,
            goal: goal,
            nextWeekGoal: nextWeekGoal,
            emoji: emoji,
            nextWeekEmoji: nextWeekEmoji,
            isReflectionCompleted: isReflectionCompleted
        )
    }
    
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
            date: date
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
    
    func getStartOfWeek(for date: Date) -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2 // 月曜日を週の開始日に設定
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return calendar.date(from: components)!
    }
    
    func getPreviousWeeklyRecord() -> WeeklyRecord? {
        if let previousWeeklyRecordEntity = coreDataManager.fetchPreviousWeekRecord(before: Date()),
           let previousWeeklyRecord = toWeeklyRecord(from: previousWeeklyRecordEntity) {
            return previousWeeklyRecord
        }
        return nil
    }
}
