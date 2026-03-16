//
//  ArchiveEmojiBubbleViews.swift
//  week
//
//  Created by Codex on 2026/03/16.
//

import ForceSimulation
import Grape
import SwiftUI
import UIKit

struct GoalEmojiBubbleSection: View {
    let title: String
    let subtitle: String
    let items: [GoalEmojiBubbleItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            PickupSectionHeader(title: title, subtitle: subtitle)
            
            if items.isEmpty {
                ArchiveEmptyStateView(
                    title: String(localized: "まだ絵文字の傾向は見えていません"),
                    message: String(localized: "週の目標が増えると、よく選ぶ絵文字がここでふくらんで見えてきます。")
                )
            } else {
                GoalEmojiBubbleCloudView(items: items)
            }
        }
    }
}

struct GoalEmojiBubbleCloudView: View {
    let items: [GoalEmojiBubbleItem]
    
    @State private var graphState = ForceDirectedGraphState(
        initialIsRunning: true,
        ticksOnAppear: .untilStable
    )
    @State private var draggingNodeID: String?
    
    private let cardCornerRadius: CGFloat = 20
    
    private var maxCount: Int {
        max(items.map(\.count).max() ?? 1, 1)
    }
    
    private var countTiers: [Int] {
        Array(Set(items.map(\.count))).sorted(by: >)
    }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cardCornerRadius)
                .fill(Color.card)
            
            bubbleGraph
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
    }
    
    private var bubbleGraph: some View {
        ForceDirectedGraph(states: graphState) {
            bubbleContent
        } force: {
            bubbleForce
        } emittingNewNodesWithStates: { nodeID in
            KineticState(position: initialNodePosition(forID: nodeID))
        }
        .clipShape(RoundedRectangle(cornerRadius: cardCornerRadius))
        .graphOverlay { proxy in
            Rectangle()
                .fill(.clear)
                .contentShape(Rectangle())
                .gesture(nodeDragGesture(proxy: proxy))
        }
    }
    
    @GraphContentBuilder<String>
    private var bubbleContent: some GraphContent<String> {
        Series(items) { item in
            bubbleNodeMark(for: item)
        }
    }
    
    private var bubbleForce: SealedForceDescriptor<String> {
        SealedForceDescriptor<String>
            .manyBody(
                strength: -18,
                mass: .varied { nodeID in
                    1.0 + nodeRadius(forID: nodeID, maxCount: maxCount) / 18
                }
            )
            .collide(
                strength: 1.0,
                radius: .varied { nodeID in
                    nodeRadius(forID: nodeID, maxCount: maxCount) + 4
                },
                iterationsPerTick: 3
            )
            .position(direction: .x, targetOnDirection: 0.0, strength: 0.05)
            .position(direction: .y, targetOnDirection: 0.0, strength: 0.05)
            .center(strength: 0.16)
    }
    
    private func bubbleNodeMark(for item: GoalEmojiBubbleItem) -> some GraphContent<String> {
        let radius = nodeRadius(for: item, maxCount: maxCount)
        
        return NodeMark(id: item.id)
            .symbolSize(radius: radius)
            .foregroundStyle(Color.gray.opacity(0.18))
            .annotation(emojiText(for: item), alignment: .center, offset: .zero)
    }
    
    private func emojiFontSize(for item: GoalEmojiBubbleItem, maxCount: Int) -> CGFloat {
        let tierSizes: [CGFloat] = [52, 38, 28, 22, 17, 14]
        guard let tierIndex = countTiers.firstIndex(of: item.count) else {
            return tierSizes.last ?? 18
        }
        return tierSizes[min(tierIndex, tierSizes.count - 1)]
    }
    
    private func nodeRadius(for item: GoalEmojiBubbleItem, maxCount: Int) -> CGFloat {
        emojiFontSize(for: item, maxCount: maxCount) * 0.72
    }
    
    private func emojiText(for item: GoalEmojiBubbleItem) -> Text {
        Text(item.emoji)
            .font(.system(size: emojiFontSize(for: item, maxCount: maxCount)))
    }
    
    private func nodeRadius(forID id: String, maxCount: Int) -> Double {
        guard let item = items.first(where: { $0.id == id }) else { return 14 }
        return nodeRadius(for: item, maxCount: maxCount)
    }
    
    private func initialNodePosition(forID id: String) -> SIMD2<Double> {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return .zero }
        
        let count = max(items.count, 1)
        let angleOffset = Double(id.unicodeScalars.reduce(0) { $0 + Int($1.value) % 17 }) * 0.07
        let angle = (Double(index) / Double(count)) * (.pi * 2) + angleOffset
        let radius = 88.0 + Double(index % 3) * 22.0
        
        return SIMD2<Double>(
            cos(angle) * radius,
            sin(angle) * radius
        )
    }
    
    private func nodeDragGesture(proxy: GraphProxy) -> some Gesture {
        DragGesture(minimumDistance: 2, coordinateSpace: .local)
            .onChanged { value in
                if draggingNodeID == nil {
                    guard let nodeID = proxy.node(of: String.self, at: value.startLocation) else {
                        return
                    }
                    triggerNodeGrabImpact()
                    draggingNodeID = nodeID
                }
                
                guard let draggingNodeID else { return }
                proxy.setNodeFixation(nodeID: draggingNodeID, fixation: value.location)
            }
            .onEnded { _ in
                if let draggingNodeID {
                    proxy.setNodeFixation(nodeID: draggingNodeID, fixation: nil)
                    triggerNodeReleaseImpact()
                }
                draggingNodeID = nil
            }
    }
    
    private func triggerNodeGrabImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.75)
    }
    
    private func triggerNodeReleaseImpact() {
        let generator = UIImpactFeedbackGenerator(style: .soft)
        generator.prepare()
        generator.impactOccurred(intensity: 0.45)
    }
}
