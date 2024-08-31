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
    @State private var textViewHeight: CGFloat = 50
    @State private var previousContent: String = ""
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0

    var body: some View {
        VStack(spacing: 10) {
            UITextViewWrapper(text: $thoughtCard.content, height: $textViewHeight, cursorPosition: $cursorPosition, adjustIndent: adjustIndent, handleEnterKey: handleEnterKey)
                .focused($isFocused)
                .frame(height: max(50, textViewHeight))
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
            DispatchQueue.main.async {
                updateTextEditorHeight()
                isFocused = true
                previousContent = thoughtCard.content
            }
        }
        .onChange(of: thoughtCard.content) { oldValue, newValue in
            DispatchQueue.main.async {
                dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: newValue)
            }
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
            let newLine = "\n\(match.0)"
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
    @Binding var cursorPosition: Int
    var adjustIndent: (Bool) -> Void
    var handleEnterKey: () -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
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

        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            if text == "\n" {
                parent.handleEnterKey()
                return false
            }
            return true
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
            parent.height = textView.contentSize.height
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
