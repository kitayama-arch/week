//
//  ThoughtCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCardView: View {
    @Binding var thoughtCard: ThoughtCard // 親ビューからバインディングされたThoughtCardデータ
    @ObservedObject var dataManager: DataManager
    @State private var showingOptions = false
    let index: Int
    @State private var textViewHeight: CGFloat = 50 // テキストエディタの高さを動的に管理するState変数
    @State private var previousContent: String = ""
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0

    var body: some View {
        VStack(spacing: 10) {
            UITextViewWrapper(text: $thoughtCard.content, height: $textViewHeight, onTextChange: { newText in
                dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: newText)
                
                // 改行を検知して処理
                if newText.last == "\n" && newText != previousContent {
                    handleEnterKey()
                }
                previousContent = newText
            }, cursorPosition: $cursorPosition)
                .focused($isFocused) // フォーカスを制御
                .frame(height: max(50, textViewHeight))
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(8)
            
            HStack {
                Button(action: { adjustIndent(increase: false) }) {
                    Image(systemName: "chevron.left")
                }
                Button(action: { adjustIndent(increase: true) }) {
                    Image(systemName: "chevron.right")
                }
            }
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
    }

    private func updateTextEditorHeight() {
        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
        let estimatedSize = thoughtCard.content.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
            context: nil
        )
        
        textViewHeight = max(50, estimatedSize.height + 20)
    }

    private func handleEnterKey() {
        let lines = thoughtCard.content.split(separator: "\n")
        if let lastLine = lines.last,
           let match = lastLine.firstMatch(of: /^\s*([•◦◾])\s*/) {
            let newLine = "\(match.0)"
            thoughtCard.content.append(newLine)
        } else {
            thoughtCard.content.append("• ")
        }
    }

    private func adjustIndent(increase: Bool) {
        let lines = thoughtCard.content.split(separator: "\n", omittingEmptySubsequences: false)
        let currentLineIndex = getCurrentLineIndex(cursorPosition: cursorPosition, in: thoughtCard.content)
        
        if currentLineIndex < lines.count {
            var currentLine = String(lines[currentLineIndex])
            if let match = currentLine.firstMatch(of: /^(\s*)([•◦◾])/) {
                let currentIndent = match.1.count / 2
                let newIndent = increase ? currentIndent + 1 : max(currentIndent - 1, 0)
                let symbol = getSymbolForIndent(newIndent)
                currentLine = String(repeating: "  ", count: newIndent) + symbol + " " + currentLine.replacing(/^\s*[•◦◾]\s*/, with: "")
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
        let symbols = ["•", "◦", "◾"]
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
    @Binding var height: CGFloat
    var onTextChange: (String) -> Void
    @Binding var cursorPosition: Int

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        
        // カスタムリストスタイルを適用
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
        
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        DispatchQueue.main.async {
            self.height = uiView.contentSize.height
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

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.height = textView.contentSize.height
            parent.onTextChange(textView.text)
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.cursorPosition = textView.selectedRange.location
        }
    }
}
