//
//  HVStack.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 19/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI


/// A wrapper that allows a HStack to change to a VStack when the sizeClass is compact
struct HVStack<Content>: View where Content: View {
    @Environment(\.horizontalSizeClass) var sizeClass

    let content: () -> Content

    init(@ViewBuilder content: @escaping () -> Content) {
        // could pass parameters for the alignment and spacing of the stacks
        self.content = content
    }

    var body: some View {
        Group {
            if sizeClass == .compact {
                AnyView(VStack(alignment: .leading) {
                    content()
                })
            } else {
                AnyView(HStack {
                    content()
                })
            }
        }
    }
}

struct HVStack_Previews: PreviewProvider {
    static var previews: some View {
        HVStack(content: { Text("Hello")})
    }
}
