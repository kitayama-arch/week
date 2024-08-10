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
    // テキストエディタの高さを動的に管理するState変数
    @State private var textEditorHeight: CGFloat = 50
    
    var body: some View {
        ZStack {
            TextEditor(text: $thoughtCard.content)
                // テキストエディタの高さを動的に設定（最小50）
                .frame(height: max(50, textEditorHeight))
                .padding(.horizontal)
                .background(Color.white)
                .cornerRadius(8)
                // テキストが変更されたときに高さを更新
                .onChange(of: thoughtCard.content) { oldValue, newValue in
                    withAnimation {
                        updateTextEditorHeight()
                    }
                    dataManager.updateThoughtCard(thoughtCard: thoughtCard, newContent: thoughtCard.content)
                }
                .padding(.horizontal)

        }
        // ZStackの高さを無限に設定し、上揃えにする
        .frame(maxHeight: .infinity, alignment: .top)
        .onAppear {
                    thoughtCard.content = thoughtCard.content // 思考の内容をセット
                    updateTextEditorHeight() // 初期高さの更新
                }
    }
    
    // テキストエディタの高さを更新する関数
    private func updateTextEditorHeight() {
        // 画面幅からパディングを引いたサイズを計算
        let size = CGSize(width: UIScreen.main.bounds.width - 40, height: .infinity)
        // テキストの実際の高さを計算
        let estimatedSize = thoughtCard.content.boundingRect(
            with: size,
            options: .usesLineFragmentOrigin,
            attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
            context: nil
        )
        
        // 計算された高さと最小高さ(50)を比較し、大きい方を採用
        // 20ピクセルの余白を追加
        textEditorHeight = max(50, estimatedSize.height + 20)
    }
}

struct ThoughtCardView_Previews: PreviewProvider {
    @State static var sampleCard = ThoughtCard(content: "Sample Thought", date: Date(), items: ["item1", "item2"])
    @State static var dataManager = DataManager()

    static var previews: some View {
        ThoughtCardView(thoughtCard: $sampleCard, dataManager: dataManager)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
