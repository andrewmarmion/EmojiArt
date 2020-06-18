//
//  Grid.swift
//  Memorize
//
//  Created by Andrew Marmion on 27/05/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

typealias IdentifiableEquatable = Identifiable & Equatable

struct Grid<Item, ID, ItemView>: View where ID: Hashable, ItemView: View  {
    
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView
    private var id: KeyPath<Item, ID>
    
    init(_ items: [Item], id: KeyPath<Item, ID>, viewForItem: @escaping (Item) -> ItemView) {
        self.items = items
        self.viewForItem = viewForItem
        self.id = id
    }
    
    var body: some View {
        GeometryReader { geometry in
            self.body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    /// A helper function to avoid using self
    /// - Parameter layout: the grid layou that will position the items
    /// - Returns: A view displaying all the items
    private func body(for layout: GridLayout) -> some View {
        ForEach(items, id: id) { item in
            self.body(for: item, in: layout)
        }
    }
    
    /// Positions each item on the screen
    /// - Parameters:
    ///   - item: the item to position
    ///   - layout: the grid layout that positions the item
    /// - Returns: A view representing our newly positioned item
    private func body(for item: Item, in layout: GridLayout) -> some View {
        guard let index = items.firstIndex(where: { item[keyPath: id] == $0[keyPath: id] }) else { fatalError("Unable to find \(item)") }
        return viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
            .position(layout.location(ofItemAt: index))
    }
}

extension Grid where Item: Identifiable, ID == Item.ID {
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {
        self.init(items, id: \Item.id, viewForItem: viewForItem)
    }
}
