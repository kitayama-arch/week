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
//            Color.gray.opacity(0.2)
            TextEditor(text: $thoughtText)
                .padding()
                .textEditorStyle(.automatic)
                .cornerRadius(10)
        }
        .padding(.horizontal)
    }
}

#Preview {
    ThoughtCardView()
}
