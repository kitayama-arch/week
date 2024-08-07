//
//  ThoughtCard.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import Foundation

struct ThoughtCard: Identifiable { // データ識別にIdentifiableプロトコルに準拠
    let id = UUID() //  UUIDで一意なIDを生成
    var content: String // 思考の内容を格納
    let date: Date //　作成日
    var items: [String]
}
// ダミーデータ
let sampleThoughtCards = [
    ThoughtCard(content: "First thought", date: Date(), items: ["item1", "item2"]),
    ThoughtCard(content: "Second thought", date: Date().addingTimeInterval(-86400), items: []),
    ThoughtCard(content: "Third thought", date: Date().addingTimeInterval(-172800), items: ["item3"])
]
