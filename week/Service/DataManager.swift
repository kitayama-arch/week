//
//  DataManager.swift
//  week
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
    @Published var shouldFocusNewCard: Bool = false
    
    static let shared = DataManager()
    
    private init() {
        loadThoughtCards()
        loadWeeklyRecords()
        #if targetEnvironment(simulator)
        if hasMissingDummyWeeklyRecords() {
            seedDummyDataForSimulator()
            loadThoughtCards()
            loadWeeklyRecords()
            loadCurrentWeekRecord()
        }
        #endif
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
            shouldFocusNewCard = true
            
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
        
        // ThoughtCardEntity を直接フェッチ
        let context = coreDataManager.getViewContext()
        let fetchRequest: NSFetchRequest<ThoughtCardEntity> = ThoughtCardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", thoughtCard.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                entity.content = newContent
                try context.save()
                print("DataManager: ThoughtCardが正常に更新されました。ID: \(thoughtCard.id)")
                
                // DataManager の thoughtCards を更新
                if let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id }) {
                    thoughtCards[index].content = newContent
                }
            } else {
                print("DataManager: 更新するThoughtCardのエンティティが見つかりませんでした。ID: \(thoughtCard.id)")
            }
        } catch {
            print("DataManager: ThoughtCardの更新に失敗しました: \(error)")
        }
    }
    
    func deleteThoughtCard(thoughtCard: ThoughtCard) {
        let context = coreDataManager.getViewContext()
        let fetchRequest: NSFetchRequest<ThoughtCardEntity> = ThoughtCardEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", thoughtCard.id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            if let entity = results.first {
                if let id = entity.id {
                    print("DataManager: Attempting to delete ThoughtCard with ID: \(id.uuidString)")
                    context.delete(entity)
                    try context.save()
                    print("CoreDataManager: ThoughtCard deleted successfully. ID: \(id.uuidString)")
                } else {
                    print("DataManager: Attempting to delete ThoughtCard with ID: Unknown")
                    context.delete(entity)
                    try context.save()
                    print("CoreDataManager: ThoughtCard deleted successfully. ID: Unknown")
                }
            } else {
                print("DataManager: ThoughtCardEntity with ID: \(thoughtCard.id) not found in Core Data.")
            }
        } catch {
            print("CoreDataManager: Failed to delete ThoughtCard: \(error)")
        }
        
        // DataManagerの配列から削除
        if let index = currentWeeklyRecord?.thoughts.firstIndex(where: { $0.id == thoughtCard.id }) {
            currentWeeklyRecord?.thoughts.remove(at: index)
        }
        if let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id }) {
            thoughtCards.remove(at: index)
        }
        
        // ThoughtCardsを再読み込みして確認
        loadThoughtCards()
        print("DataManager: Reloaded ThoughtCards. Current count: \(thoughtCards.count)")
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
            // 現在の週のレコードが存在する場合
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
            // 現在の週のレコードが存在しない場合
            if let previousWeeklyRecordEntity = coreDataManager.fetchPreviousWeekRecord(before: Date()),
               let previousWeeklyRecord = toWeeklyRecord(from: previousWeeklyRecordEntity) {
                if previousWeeklyRecord.isReflectionCompleted {
                    // 前の週の振り返りが完了している場合、新しい週のレコードを作成
                    if let newWeeklyRecord = createNextWeeklyRecord(previousWeeklyRecord: previousWeeklyRecord) {
                        self.currentWeeklyRecord = newWeeklyRecord
                        print("DataManager: 新しい週の WeeklyRecord を作成しました: \(String(describing: self.currentWeeklyRecord))")
                    } else {
                        self.currentWeeklyRecord = nil
                        print("DataManager: 新しい WeeklyRecord の作成に失敗しました")
                    }
                } else {
                    self.currentWeeklyRecord = nil
                    print("DataManager: 前の週の振り返りが未完了のため、currentWeeklyRecord は nil です")
                }
            } else {
                // 前の週のレコードが存在しない場合、デフォルトのレコードを作成
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
    
    #if targetEnvironment(simulator)
    /// シミュレータで不足しているダミーデータだけ投入する
    private func seedDummyDataForSimulator() {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let now = Date()
        let currentWeekStart = getStartOfWeek(for: now)

        let dummyWeeks: [(weeksAgo: Int, goal: String, emoji: String, thoughts: [String], reflection: String, nextWeekGoal: String)] = [
            (
                1,
                "運動を三日坊主で終わらせず、平日でも短時間で続けられる形を探しながら、体力の底上げを一週間通して意識する",
                "💪",
                [
                    "仕事終わりで疲れていたけれど、走る距離を短めに決めてから外に出たら気持ちのハードルがかなり下がって、結果的に先週より継続しやすかった。",
                    "プロテインを飲む時間を固定したことで、運動した日の流れが少しずつ習慣としてつながってきた感覚がある。",
                    "足の重さが残る日もあったが、完全に休むよりストレッチだけでもやると翌日のだるさが軽くなると分かった。"
                ],
                "勢いだけで頑張るより、疲れている日でも続けられる最小単位を決めておく方が習慣化には効いた。達成感を毎回大きくしようとしない方が、結果的に継続しやすい。",
                "読書を毎日三十分続けつつ、感じたことを一行でもメモに残して理解を浅いまま流さない"
            ),
            (
                2,
                "早起きを根性論にせず、夜の過ごし方から整えて、朝に余白のある状態で一日を始められるようにする",
                "🌅",
                [
                    "六時に起きられた日は、その後の準備に追われず落ち着いて朝食を取れたので、一日の焦り方がかなり違った。",
                    "夜にスマホをだらだら見始めると就寝時間がすぐ崩れるので、充電場所をベッドから離したのは地味だが効果があった。",
                    "起床直後は眠くても、カーテンを開けて水を飲むまでをセットにすると二度寝しにくくなった。"
                ],
                "早起きそのものより、前日の行動設計の方が成功率に直結していた。朝だけ改善しようとすると再現性が低いが、夜のだらつきを減らすと安定した。",
                "朝の時間に五分だけでも瞑想を入れて、起きた直後のぼんやりを引きずらないようにする"
            ),
            (
                3,
                "勉強時間の長さではなく、毎日どこまで理解が進んだかを振り返れる状態をつくって、学習を惰性にしない",
                "📚",
                [
                    "英語の勉強では単語を眺めるだけの日より、短い例文を声に出した日の方が記憶の残り方がはっきりしていた。",
                    "プログラミング学習は動画を見るだけだと分かった気になりやすく、手を動かして小さく再現した方が理解の穴に気づけた。",
                    "資格の勉強では、新しい範囲に進むより前日に迷ったポイントを解き直した方が、知識のつながりが見えやすかった。",
                    "復習メモを一行ずつでも残すと、翌日に何を見直すべきかがすぐ分かって再開コストが下がった。"
                ],
                "学習量だけを追うと満足してしまうが、説明できない部分を書き出すと理解の浅さが見えた。毎日の終わりに小さく整理するだけでも、次の日の質が変わる。",
                "学んだ内容を短く人に説明する前提でまとめて、理解したつもりを減らす"
            )
        ]

        for dummy in dummyWeeks {
            let weekStart = calendar.date(byAdding: .day, value: -7 * dummy.weeksAgo, to: currentWeekStart)!
            let weekEnd = calendar.date(byAdding: .day, value: 6, to: weekStart)!
            guard !hasDummyWeeklyRecord(startDate: weekStart, goal: dummy.goal) else { continue }

            guard let weeklyEntity = coreDataManager.createWeeklyRecord(
                startDate: weekStart,
                endDate: weekEnd,
                goal: dummy.goal,
                emoji: dummy.emoji
            ) else { continue }
            
            for (dayOffset, thoughtContent) in dummy.thoughts.enumerated() {
                let thoughtDate = calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
                _ = coreDataManager.createThoughtCard(content: thoughtContent, date: thoughtDate, weeklyRecord: weeklyEntity)
            }
            
            if !dummy.reflection.isEmpty {
                coreDataManager.updateWeeklyRecord(
                    weeklyRecord: weeklyEntity,
                    reflection: dummy.reflection,
                    nextWeekGoal: dummy.nextWeekGoal,
                    goal: dummy.goal,
                    emoji: dummy.emoji,
                    nextWeekEmoji: dummy.emoji,
                    isReflectionCompleted: true
                )
            }
        }
        print("DataManager: シミュレータ用ダミーデータを投入しました")
    }

    private func hasMissingDummyWeeklyRecords() -> Bool {
        var calendar = Calendar.current
        calendar.firstWeekday = 2
        let currentWeekStart = getStartOfWeek(for: Date())

        let dummySignatures: [(weeksAgo: Int, goal: String)] = [
            (1, "運動を三日坊主で終わらせず、平日でも短時間で続けられる形を探しながら、体力の底上げを一週間通して意識する"),
            (2, "早起きを根性論にせず、夜の過ごし方から整えて、朝に余白のある状態で一日を始められるようにする"),
            (3, "勉強時間の長さではなく、毎日どこまで理解が進んだかを振り返れる状態をつくって、学習を惰性にしない")
        ]

        return dummySignatures.contains { signature in
            let weekStart = calendar.date(byAdding: .day, value: -7 * signature.weeksAgo, to: currentWeekStart)!
            return !hasDummyWeeklyRecord(startDate: weekStart, goal: signature.goal)
        }
    }

    private func hasDummyWeeklyRecord(startDate: Date, goal: String) -> Bool {
        weeklyRecords.contains { record in
            record.startDate == startDate && record.goal == goal
        }
    }
    #endif
}
