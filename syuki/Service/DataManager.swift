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
        thoughtCards = thoughtCardEntities.compactMap { entity in
            guard let id = entity.id,
                  let content = entity.content,
                  let date = entity.date,
                  let items = entity.items else { return nil }
            return ThoughtCard(id:id, content: content, date: date, items: items)
        }
    }
}
