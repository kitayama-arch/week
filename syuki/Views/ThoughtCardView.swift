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
    @State private var previousContent: String = ""
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            UITextViewWrapper(
                text: $thoughtCard.content,
                cursorPosition: $cursorPosition
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
            isFocused = true
            previousContent = thoughtCard.content
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
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = UIFont.preferredFont(forTextStyle: .body)
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        return textView
    }
    func updateUIView(_ uiView: UITextView, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: UITextViewWrapper
        
        init(_ parent: UITextViewWrapper) {
            self.parent = parent
        }
    }
}
