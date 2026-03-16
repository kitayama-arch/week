//
//  ArchiveSearchViews.swift
//  week
//
//  Created by Codex on 2026/03/16.
//

import SwiftUI
import UIKit

struct SearchResultsContainerView: View {
    let results: [SearchMatchItem]
    let searchQuery: String
    let resetToken: Int
    let onSelect: (WeeklyRecord) -> Void
    let onBackgroundTap: () -> Void
    
    private let topID = "search-results-top"
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: 0)
                        .id(topID)
                    
                    SearchResultsView(
                        results: results,
                        searchQuery: searchQuery,
                        onSelect: onSelect
                    )
                }
                .padding(.bottom, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .mask(ArchiveTopFadeMask())
            .scrollDismissesKeyboard(.immediately)
            .ignoresSafeArea(.container, edges: .bottom)
            .simultaneousGesture(
                TapGesture().onEnded {
                    onBackgroundTap()
                }
            )
            .onChange(of: resetToken) { _, _ in
                withAnimation {
                    proxy.scrollTo(topID, anchor: .top)
                }
            }
            .onChange(of: searchQuery) { _, _ in
                proxy.scrollTo(topID, anchor: .top)
            }
        }
    }
}

struct NativeSearchBar: UIViewRepresentable {
    @Binding var text: String
    @Binding var isEditing: Bool
    let placeholder: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, isEditing: $isEditing)
    }
    
    func makeUIView(context: Context) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = .clear
        searchBar.placeholder = placeholder
        searchBar.searchTextField.autocorrectionType = .no
        searchBar.searchTextField.autocapitalizationType = .none
        searchBar.searchTextField.returnKeyType = .search
        searchBar.searchTextField.enablesReturnKeyAutomatically = false
        searchBar.searchTextField.backgroundColor = .secondarySystemFill
        return searchBar
    }
    
    func updateUIView(_ searchBar: UISearchBar, context: Context) {
        if searchBar.text != text {
            searchBar.text = text
        }
        
        if searchBar.placeholder != placeholder {
            searchBar.placeholder = placeholder
        }
        
        if searchBar.showsCancelButton != isEditing {
            searchBar.setShowsCancelButton(isEditing, animated: true)
        }
        
        if !isEditing, searchBar.searchTextField.isFirstResponder {
            searchBar.searchTextField.resignFirstResponder()
        }
    }
    
    final class Coordinator: NSObject, UISearchBarDelegate {
        @Binding var text: String
        @Binding var isEditing: Bool
        
        init(text: Binding<String>, isEditing: Binding<Bool>) {
            _text = text
            _isEditing = isEditing
        }
        
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
            isEditing = true
            searchBar.setShowsCancelButton(true, animated: true)
        }
        
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
            isEditing = false
            searchBar.setShowsCancelButton(false, animated: true)
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            dismiss(searchBar)
        }
        
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            dismiss(searchBar)
        }
        
        private func dismiss(_ searchBar: UISearchBar) {
            isEditing = false
            searchBar.setShowsCancelButton(false, animated: true)
            searchBar.searchTextField.resignFirstResponder()
        }
    }
}

struct SearchResultsView: View {
    let results: [SearchMatchItem]
    let searchQuery: String
    let onSelect: (WeeklyRecord) -> Void
    
    private var groupedByKind: [(SearchMatchKind, [SearchMatchItem])] {
        let grouped = Dictionary(grouping: results, by: \.kind)
        return [SearchMatchKind.goal, .thought, .reflection].compactMap { kind in
            guard let items = grouped[kind], !items.isEmpty else { return nil }
            return (kind, items)
        }
    }
    
    var body: some View {
        if results.isEmpty {
            VStack(alignment: .leading, spacing: 0) {
                Text(String(localized: "検索結果がありません"))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 40)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
        } else {
            LazyVStack(alignment: .leading, spacing: 20) {
                ForEach(Array(groupedByKind.enumerated()), id: \.offset) { _, group in
                    let (kind, items) = group
                    VStack(alignment: .leading, spacing: 8) {
                        Text(kind.sectionTitle)
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 4)
                        
                        ForEach(items) { item in
                            SearchResultRowView(
                                item: item,
                                searchQuery: searchQuery
                            )
                            .onTapGesture {
                                onSelect(item.weeklyRecord)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct SearchResultRowView: View {
    @Environment(\.colorScheme) private var colorScheme
    let item: SearchMatchItem
    let searchQuery: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(ArchiveDateFormatter.dayRangeString(
                startDate: item.weeklyRecord.startDate,
                endDate: item.weeklyRecord.endDate
            ))
            .font(.caption)
            .foregroundStyle(.secondary)
            
            highlightedExcerpt(item.excerpt, query: searchQuery)
                .font(.subheadline)
                .lineLimit(3)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.card)
        .cornerRadius(10)
        .padding(.horizontal, 4)
    }
    
    private func highlightedExcerpt(_ text: String, query: String) -> Text {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedQuery.isEmpty {
            return Text(text)
        } else {
            let segments = buildHighlightSegments(text: text, query: trimmedQuery)
            if segments.isEmpty {
                return Text(text)
            } else {
                var attributed = AttributedString(text)
                attributed.foregroundColor = UIColor.label
                let highlightColor = UIColor(
                    red: colorScheme == .dark ? 188 / 255 : 212 / 255,
                    green: colorScheme == .dark ? 225 / 255 : 1.0,
                    blue: 0,
                    alpha: colorScheme == .dark ? 0.72 : 0.85
                )
                var currentIndex = attributed.startIndex
                
                for segment in segments {
                    let segmentEnd = attributed.index(currentIndex, offsetByCharacters: segment.text.count)
                    if segment.isHighlight {
                        attributed[currentIndex..<segmentEnd].backgroundColor = highlightColor
                        attributed[currentIndex..<segmentEnd].foregroundColor = UIColor.label
                    }
                    currentIndex = segmentEnd
                }
                
                return Text(attributed)
            }
        }
    }
    
    private func buildHighlightSegments(text: String, query: String) -> [(isHighlight: Bool, text: String)] {
        let nsText = text as NSString
        let nsLower = text.lowercased() as NSString
        let qLower = query.lowercased()
        var segments: [(isHighlight: Bool, text: String)] = []
        var searchStart = 0
        
        while searchStart < nsLower.length {
            let range = nsLower.range(
                of: qLower,
                options: .caseInsensitive,
                range: NSRange(location: searchStart, length: nsLower.length - searchStart)
            )
            if range.location == NSNotFound { break }
            if searchStart < range.location {
                segments.append((false, nsText.substring(with: NSRange(
                    location: searchStart,
                    length: range.location - searchStart
                ))))
            }
            segments.append((true, nsText.substring(with: range)))
            searchStart = range.location + range.length
        }
        
        if searchStart < nsText.length {
            segments.append((false, nsText.substring(from: searchStart)))
        }
        
        return segments
    }
}
