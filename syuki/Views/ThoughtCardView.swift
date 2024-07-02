//
//  ThoughtCardView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/07/02.
//

import SwiftUI

struct ThoughtCardView: View {
    @State private var thoughtText = ""
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
            TextEditor(text: $thoughtText)
                .padding()
                .frame(height: 120)
                .textEditorStyle(.plain)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ThoughtCardView()
}
