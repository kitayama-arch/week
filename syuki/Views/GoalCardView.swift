//
//  GoalCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct GoalCardView: View {
    @State private var goalText = "" // 入力された目標を保持

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 60)
            TextField("今週の目標を入力", text: $goalText) // TextFieldを追加
                .padding()
        }
        .padding(.horizontal)
    }
}

#Preview {
    GoalCardView()
}
