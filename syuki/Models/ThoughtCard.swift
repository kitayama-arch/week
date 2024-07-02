//
//  ThoughtCard.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCard: Identifiable { // データ識別にIdentifiableプロトコルに準拠
    let id = UUID() //  UUIDで一意なIDを生成
    var content: String // 思考の内容を格納
}
