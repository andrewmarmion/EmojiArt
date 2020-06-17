//
//  OutlineModifier.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct OutlineModifier: ViewModifier {

    let showOutline: Bool

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(lineWidth: showOutline ? 2 : 0)
                .foregroundColor(.blue)
        )
    }
}

extension View {
    func showOutline(showOutline: Bool) -> some View {
        self.modifier(OutlineModifier(showOutline: showOutline))
    }
}
