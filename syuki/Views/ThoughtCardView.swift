//
//  ThoughtCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCardView: View {
    @Binding var thoughtCard: ThoughtCard
    @ObservedObject var dataManager: DataManager
    @State private var showingOptions = false
    let index: Int
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            UITextViewWrapper(text: $thoughtCard.content, cursorPosition: $cursorPosition, adjustIndent: { increase in adjustIndent(increase: increase) }, handleEnterKey: handleEnterKey)
                .focused($isFocused)
                .padding(.horizontal)
                .background(Color.white)
            .cornerRadius(8)        }
        .padding()
        .overlay(
            Button(action: { showingOptions = true }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
                    .padding(.trailing, 8)
            }
                .confirmationDialog("確認", isPresented: $showingOptions) {
                    Button("削除") {
                        let indexSet = IndexSet(integer: index)
                        dataManager.deleteThoughtCard(at: indexSet)
                    }
                },
            alignment: .topTrailing
        )
        .onAppear {
            isFocused = true
        }
    }
    
    
    private func handleEnterKey() {
        let lines = thoughtCard.content.split(separator: "\n")
        if let lastLine = lines.last,
           let match = lastLine.firstMatch(of: /^\s*([•◦◼])\s*/) { // Regexリテラル
            let newLine = "\n\(match.0)" // インデント部分を抽出
            thoughtCard.content.append(newLine)
        } else {
            thoughtCard.content.append("\n• ")
        }
    }
    
    private func adjustIndent(increase: Bool) {
        let lines = thoughtCard.content.split(separator: "\n", omittingEmptySubsequences: false)
        let currentLineIndex = getCurrentLineIndex(cursorPosition: cursorPosition, in: thoughtCard.content)
        
        if currentLineIndex < lines.count {
            var currentLine = String(lines[currentLineIndex])
            let regex = try! Regex(#"^(\s*)([•◦◼]) (.*)"#)
            if let match = currentLine.wholeMatch(of: regex) {
                // サブグループ全体をループ処理
                var substrings = [String]()
                for i in 0..<match.output.count {
                    // substring プロパティを使ってサブグループの値を取得
                    if let substring = match.output[i].substring {
                        substrings.append(String(substring))
                    } else {
                        substrings.append("")
                    }
                }
                
                // インデックスでサブグループにアクセス
                let indent = substrings[1]
                let symbol = substrings[2]
                let content = substrings[3]
                
                let newIndent = increase ? indent + "  " : indent.count > 2 ? String(indent.dropLast(2)) : ""
                currentLine = "\(newIndent)\(symbol) \(content)"
            }
            
            var updatedLines = lines
            updatedLines[currentLineIndex] = Substring(currentLine)
            thoughtCard.content = updatedLines.joined(separator: "\n")
        }
    }
    
    private func getCurrentLineIndex(cursorPosition: Int, in text: String) -> Int {
        let lines = text.split(separator: "\n", omittingEmptySubsequences: false)
        var currentIndex = 0
        var characterCount = 0
        
        for (index, line) in lines.enumerated() {
            characterCount += line.count + 1 // +1 for newline character
            if characterCount > cursorPosition {
                currentIndex = index
                break
            }
        }
        
        return currentIndex
    }
    
    private func getSymbolForIndent(_ indent: Int) -> String {
        let symbols = ["•", "◦", "◼"]
        return symbols[indent % symbols.count]
    }
}

struct ThoughtCardView_Previews: PreviewProvider {
    @State static var sampleCard = ThoughtCard(content: "Sample Thought", date: Date(), items: ["item1", "item2"])
    @State static var dataManager = DataManager()
    
    static var previews: some View {
        ThoughtCardView(thoughtCard: $sampleCard, dataManager: dataManager, index: 0)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var cursorPosition: Int
    var adjustIndent: (Bool) -> Void
    var handleEnterKey: () -> Void
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false // スクロール無効化
        textView.backgroundColor = .clear
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.headIndent = 15
        paragraphStyle.firstLineHeadIndent = 0
        paragraphStyle.tailIndent = -15
        paragraphStyle.paragraphSpacingBefore = 2
        paragraphStyle.paragraphSpacing = 2
        paragraphStyle.lineSpacing = 1
        
        textView.typingAttributes = [
            .paragraphStyle: paragraphStyle,
            .font: UIFont.preferredFont(forTextStyle: .body)
        ]
        
        // inputAccessoryViewの設定
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            // インデント調整ボタンを追加
            UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: context.coordinator, action: #selector(Coordinator.decreaseIndent)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: context.coordinator, action: #selector(Coordinator.increaseIndent)),
            UIBarButtonItem(title: "完了", style: .done, target: context.coordinator, action: #selector(Coordinator.doneEditing))
        ]
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        private var updateTimer: Timer?
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                parent.handleEnterKey()
                return false
            }
            
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.markedTextRange == nil { // 変換確定時のみ更新
                parent.text = textView.text
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.cursorPosition = textView.selectedRange.location
        }
        
        @objc func decreaseIndent() {
            parent.adjustIndent(false)
        }
        
        @objc func increaseIndent() {
            parent.adjustIndent(true)
        }
        
        @objc func doneEditing() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
