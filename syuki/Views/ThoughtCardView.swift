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
    @State private var textViewHeight: CGFloat = 50
    @State private var previousContent: String = ""
    
    var body: some View {
        VStack(spacing: 10) {
            UITextViewWrapper(
                text: $thoughtCard.content,
                cursorPosition: $cursorPosition,
                onEditingChanged: {
                    // 編集状態が変更された時の処理
                    self.handleTextChange()
                }
            )
            .focused($isFocused)
            .padding(.horizontal)
            .background(Color.white)
            .cornerRadius(8)
        }
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
            updateTextEditorHeight()
            isFocused = true
            previousContent = thoughtCard.content
        }
        .onChange(of: thoughtCard.content) { oldValue, newValue in
            if oldValue != newValue {
                print("onChange triggered. Old value: \(oldValue), New value: \(newValue)")
                Task {
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒待機
                    if thoughtCard.content == newValue { // 0.5秒後も内容が同じであれば更新
                        await MainActor.run {
                            print("Updating thought card content in DataManager")
                            dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: newValue)
                        }
                    }
                }
            }
        }
    }
    
    private func handleTextChange() {
        // 1. 現在の行のインデントと記号を判定
        let lines = thoughtCard.content.split(separator: "\n", omittingEmptySubsequences: false)
        let currentLineIndex = getCurrentLineIndex(cursorPosition: cursorPosition, in: thoughtCard.content)
        if currentLineIndex < lines.count {
            let currentLine = String(lines[currentLineIndex])
            if let match = matchRegex(pattern: #"^(\s*)([•◦◼])\s*"#, in: currentLine) {
                let currentIndent = match[1]
                let currentSymbol = match[2]
                
                // 2. 直前の行のインデントと記号を判定
                if currentLineIndex > 0 {
                    let previousLine = String(lines[currentLineIndex - 1])
                    if let previousMatch = matchRegex(pattern: #"^(\s*)([•◦◼])\s*"#, in: previousLine) {
                        let previousIndent = previousMatch[1]
                        let previousSymbol = previousMatch[2]
                        
                        // 3. 直前の行と同じインデントと記号を適用
                        if currentIndent != previousIndent || currentSymbol != previousSymbol {
                            let updatedLine = "\(previousIndent)\(previousSymbol) \(currentLine.trimmingCharacters(in: .whitespacesAndNewlines))"
                            var updatedLines = lines
                            updatedLines[currentLineIndex] = Substring(updatedLine)
                            thoughtCard.content = updatedLines.joined(separator: "\n")
                        }
                    }
                }
            } else if currentLine.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                // 4. 記号がない場合は追加
                let previousLineIndex = currentLineIndex > 0 ? currentLineIndex - 1 : 0
                let previousLine = String(lines[previousLineIndex])
                if let previousMatch = matchRegex(pattern: #"^(\s*)([•◦◼])\s*"#, in: previousLine) {
                    let previousIndent = previousMatch[1]
                    let previousSymbol = previousMatch[2]
                    let updatedLine = "\(previousIndent)\(previousSymbol) \(currentLine.trimmingCharacters(in: .whitespacesAndNewlines))"
                    var updatedLines = lines
                    updatedLines[currentLineIndex] = Substring(updatedLine)
                    thoughtCard.content = updatedLines.joined(separator: "\n")
                } else {
                    thoughtCard.content = "• \(thoughtCard.content)"
                }
            }
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
    
    private func updateTextEditorHeight() {
        let attributedString = NSAttributedString(string: thoughtCard.content, attributes: [
            .font: UIFont.preferredFont(forTextStyle: .body)
        ])
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        let textContainer = NSTextContainer(size: CGSize(width: UIScreen.main.bounds.width - 32, height: CGFloat.greatestFiniteMagnitude))
        layoutManager.addTextContainer(textContainer)
        textViewHeight = layoutManager.usedRect(for: textContainer).height
    }
    
    private func matchRegex(pattern: String, in text: String) -> [String]? {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            if let match = results.first {
                return (0..<match.numberOfRanges).map { match.range(at: $0).location != NSNotFound ? nsString.substring(with: match.range(at: $0)) : "" }
            }
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
        }
        return nil
    }
}

struct UITextViewWrapper: UIViewRepresentable {
    @Binding var text: String
    @Binding var cursorPosition: Int
    var onEditingChanged: () -> Void // 編集状態が変更された時に呼び出されるコールバック
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        
        // inputAccessoryViewの設定
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        toolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: context.coordinator, action: #selector(Coordinator.decreaseIndent)),
            UIBarButtonItem(image: UIImage(systemName: "chevron.right"), style: .plain, target: context.coordinator, action: #selector(Coordinator.increaseIndent)),
            UIBarButtonItem(title: "完了", style: .done, target: context.coordinator, action: #selector(Coordinator.doneEditing))
        ]
        textView.inputAccessoryView = toolbar
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // テキストの変更を検知
            self.parent.text = textView.text
            self.parent.onEditingChanged() // 編集状態が変更されたことを通知
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            // カーソル位置の変更を検知
            self.parent.cursorPosition = textView.selectedRange.location
        }
        
        @objc func decreaseIndent() {
            // parent（UITextViewWrapper）経由で ThoughtCardView の adjustIndent を呼び出す
            parent.onEditingChanged() // ThoughtCardView の handleTextChange を実行
        }
        
        @objc func increaseIndent() {
            // parent（UITextViewWrapper）経由で ThoughtCardView の adjustIndent を呼び出す
            parent.onEditingChanged() // ThoughtCardView の handleTextChange を実行
        }
        
        @objc func doneEditing() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
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
