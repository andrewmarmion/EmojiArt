//
//  EmojiOffsetModifer.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct EmojiOffset: ViewModifier {

    let isSelected: Bool
    let offset: CGSize

    func body(content: Content) -> some View {
        if isSelected {
            return AnyView(content.offset(offset))
        } else {
            return AnyView(content)
        }
    }

}

extension View {
    func offset(isSelected: Bool, offset: CGSize) -> some View {
        self.modifier(EmojiOffset(isSelected: isSelected, offset: offset))
    }
}
