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
    // テキストエディタの高さを動的に管理するState変数
    @State private var textEditorHeight: CGFloat = 50
    @FocusState private var isFocused: Bool
    @State private var previousContent: String = ""

    var body: some View {
        VStack(spacing: 10) {
            TextEditor(text: $thoughtCard.content)
                .frame(height: max(50, textEditorHeight))
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(8)
                .focused($isFocused)
                .onChange(of: thoughtCard.content) { oldValue, newValue in
                    withAnimation {
                        updateTextEditorHeight()
                    }
                    dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: thoughtCard.content)
                    
                    // 改行を検知して処理
                    if newValue.last == "\n" && newValue != previousContent {
                        handleEnterKey()
                    }
                    previousContent = newValue
                }
            
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
        
        textEditorHeight = max(50, estimatedSize.height + 20)
    }

    private func handleEnterKey() {
        let lines = thoughtCard.content.split(separator: "\n")
        if let lastLine = lines.last,
           let match = lastLine.firstMatch(of: /^\s*([-+*])\s*/) {
            let newLine = "\(match.0)"
            thoughtCard.content.append(newLine)
        } else {
            thoughtCard.content.append("- ")
        }
    }

    private func adjustIndent(increase: Bool) {
        let lines = thoughtCard.content.split(separator: "\n")
        let updatedLines = lines.map { line -> String in
            var currentLine = String(line)
            if let match = currentLine.firstMatch(of: /^(\s*)([-+*])/) {
                let currentIndent = match.1.count / 2
                let newIndent = increase ? currentIndent + 1 : max(currentIndent - 1, 0)
                let symbol = getSymbolForIndent(newIndent)
                currentLine = String(repeating: "  ", count: newIndent) + symbol + " " + currentLine.replacing(/^\s*[-+*]\s*/, with: "")
            }
            return currentLine
        }
        thoughtCard.content = updatedLines.joined(separator: "\n")
    }

    private func getSymbolForIndent(_ indent: Int) -> String {
        let symbols = ["-", "+", "*"]
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
