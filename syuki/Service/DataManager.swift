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
    }
    
    private func loadThoughtCards() {
        let thoughtCardEntities = coreDataManager.readThoughtCards()
        thoughtCards = thoughtCardEntities.compactMap { entity -> ThoughtCard? in
            guard let id = entity.id,
                  let content = entity.content,
                  let date = entity.date,
                  let items = entity.items else { return nil }
            return ThoughtCard(content: content, date: date, items: items)
        }
    }
    
    func createThoughtCard(content: String, date: Date, items: [String]) {
        if let entity = coreDataManager.createThoughtCard(content: content, date: date, items: items) {
            guard let content = entity.content,
                  let date = entity.date,
                  let items = entity.items else {
                print("ThoughtCardの作成に失敗しました:データのアンラップに失敗")
                return
            }
            
            let newThoughtCard = ThoughtCard(content: content, date: date, items: items)
            thoughtCards.append(newThoughtCard)
        } else {
            print("ThoughtCardの作成に失敗しました")
        }
    }
    func updateThoughtCard(thoughtCard: ThoughtCard, newContent: String) {
        guard let index = thoughtCards.firstIndex(where: { $0.id == thoughtCard.id}),
              let entity = coreDataManager.readThoughtCards().first(where: { $0.id == thoughtCard.id}) else { return }
        
        coreDataManager.updateThoughtCard(thoughtCard: entity, newContent: newContent)
        thoughtCards[index].content = newContent
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
}
