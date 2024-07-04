//
//  GoalCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI
import MCEmojiPicker

struct GoalCardView: View {
    @State private var goalText = "" // 入力された目標を保持
    @State private var selectedEmoji: String = "😀" // 選択された絵文字を保持
    @State private var isPickerPresented: Bool = false // 絵文字ピッカーの表示状態を管理

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(height: 60)
            HStack {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    Text(selectedEmoji)
                        .font(.largeTitle)
                }
                .emojiPicker(isPresented: $isPickerPresented, selectedEmoji: $selectedEmoji) // 修飾子を追加
                Divider()
                    .frame(height: 40)
                TextField("今週の目標を入力", text: $goalText) // TextFieldを追加
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GoalCardView()
}
