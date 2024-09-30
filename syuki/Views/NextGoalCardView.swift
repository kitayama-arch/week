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
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    Text(nextWeekEmoji)
                        .font(.largeTitle)
                        .shadow(color: .gray.opacity(0.5), radius: 10, x: 0.0, y: 0.0)
                }
                .emojiPicker(isPresented: $isPickerPresented, selectedEmoji: $nextWeekEmoji)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1.5, height: 40)
                    .cornerRadius(1)
                
                TextField("来週の目標を入力してください", text: $nextWeekGoal) // TextFieldを追加
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
