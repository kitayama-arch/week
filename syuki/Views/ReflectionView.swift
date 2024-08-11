//
//  ReflectionView.swift
//  syuki
//
//  Created by Ta-MacbookAir on 2024/08/11.
//

import SwiftUI

struct ReflectionView: View {
    
    
    var body: some View {
        VStack {
            Text("今週の目標")
            //今週のThoughtCard
            TextEditor(text: .constant("Placeholder"))
        }
    }
}

#Preview {
    ReflectionView()
}
