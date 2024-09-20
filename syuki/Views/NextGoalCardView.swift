//
//  NextGoalCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/13.
//

import SwiftUI
import MCEmojiPicker

struct NextGoalCardView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var nextWeekGoal: String
    @Binding var nextWeekEmoji: String
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
                    Text(nextWeekEmoji)
                        .font(.largeTitle)
                }
                .emojiPicker(isPresented: $isPickerPresented, selectedEmoji: $nextWeekEmoji) // 修飾子を追加
                Divider()
                    .frame(height: 40)
                TextField("来週の目標を入力", text: $nextWeekGoal) // TextFieldを追加
            }
            .padding(.horizontal)
        }
    }
}

struct NextGoalCardView_Previews: PreviewProvider {
    @State static var previewNextWeekGoal = "次週の目標をここに入力"
    @State static var previewNextWeekEmoji = "💡"
    
    static var previews: some View {
        NextGoalCardView(nextWeekGoal: $previewNextWeekGoal, nextWeekEmoji: $previewNextWeekEmoji)
    }
}
