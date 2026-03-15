//
//  NextGoalCardView.swift
//  week
//
//  Created by Ta-MacbookAir on 2024/08/13.
//

import SwiftUI
import MCEmojiPicker

struct NextGoalCardView: View {
    @EnvironmentObject var dataManager: DataManager
    @Binding var nextWeekGoal: String
    @Binding var nextWeekEmoji: String
    var isFirstResponder: Binding<Bool> = .constant(false)
    var pickerArrowDirection: MCPickerArrowDirection? = nil
    var pickerCustomHeight: CGFloat? = nil
    @State private var isPickerPresented: Bool = false // 絵文字ピッカーの表示状態を管理

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.card)
                .frame(height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            HStack {
                Button(action: {
                    isPickerPresented.toggle()
                }) {
                    ZStack {
                        Text(nextWeekEmoji)
                            .blur(radius: 10).opacity(0.5)
                            .font(.largeTitle)
                        Text(nextWeekEmoji)
                            .font(.largeTitle)
                    }
                }
                .emojiPicker(
                    isPresented: $isPickerPresented,
                    selectedEmoji: $nextWeekEmoji,
                    arrowDirection: pickerArrowDirection,
                    customHeight: pickerCustomHeight
                )
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1.5, height: 40)
                    .cornerRadius(1)
                
                FocusableTextField(
                    placeholder: "来週の目標を入力してください",
                    text: $nextWeekGoal,
                    isFirstResponder: isFirstResponder
                )
            }
            .padding(.horizontal)
        }
    }
}

private struct FocusableTextField: UIViewRepresentable {
    let placeholder: String
    @Binding var text: String
    @Binding var isFirstResponder: Bool
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        textField.accessibilityLabel = placeholder
        textField.borderStyle = .none
        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textDidChange(_:)), for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.placeholder = placeholder
        uiView.accessibilityLabel = placeholder
        
        if isFirstResponder, !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFirstResponder, uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
    }
    
    static func dismantleUIView(_ uiView: UITextField, coordinator: Coordinator) {
        uiView.delegate = nil
    }
    
    final class Coordinator: NSObject, UITextFieldDelegate {
        var parent: FocusableTextField
        
        init(_ parent: FocusableTextField) {
            self.parent = parent
        }
        
        @objc func textDidChange(_ textField: UITextField) {
            parent.text = textField.text ?? ""
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.isFirstResponder = true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.isFirstResponder = false
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
