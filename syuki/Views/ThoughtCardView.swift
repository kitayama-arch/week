//
//  ThoughtCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCardView: View {
    @Binding var thoughtCard: ThoughtCard // 親ビューからバインディングされたThoughtCardデータ
    @ObservedObject var dataManager: DataManager // 共有インスタンスを受け取る(UIのみだから保持する必要がない)
    @State private var showingOptions = false
    @FocusState private var isFocused: Bool
    @State private var cursorPosition: Int = 0
    
    var body: some View {
        VStack(spacing: 10) {
            TextEditor(text: $thoughtCard.content)
                .focused($isFocused)
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(8)
                .frame(height: textEditorHeight)
                .onChange(of: thoughtCard.content) { oldValue, newValue in
                    dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: newValue)
                }
                .onLongPressGesture {
                    showingOptions = true
                }
        }
        .confirmationDialog("確認", isPresented: $showingOptions) {
            Button("削除") {
                dataManager.deleteThoughtCard(thoughtCard: thoughtCard)
            }
        }
        .padding(10)
    }
    // TextEditorの高さを動的に計算するプロパティ
    private var textEditorHeight: CGFloat {
        let estimatedSize = thoughtCard.content.size(withAttributes: [.font: UIFont.preferredFont(forTextStyle: .body)])
        return max(50, estimatedSize.height + 50)
    }
}

struct ThoughtCardView_Previews: PreviewProvider {
    @State static var sampleCard = ThoughtCard(id: UUID(), content: "サンプル", date: Date())
    
    static var previews: some View {
        ThoughtCardView(thoughtCard: $sampleCard, dataManager: DataManager.shared)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
