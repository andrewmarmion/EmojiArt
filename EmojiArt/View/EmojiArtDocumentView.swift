//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {

    @ObservedObject var document: EmojiArtDocument

    var body: some View {
        VStack {
            // Emoji Selector
            ScrollView(.horizontal, showsIndicators: true) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: self.defaultEmojiSize))
                            .onDrag {
                                return NSItemProvider(object: emoji as NSString) // from ObjC we need it to be NSString
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Canvas
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .overlay(
                            Group {
                                if self.document.backgroundImage != nil {
                                    Image(uiImage: self.document.backgroundImage!)
                                }
                            }
                    )
                        .edgesIgnoringSafeArea([.horizontal, .bottom])
                        .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                            var location = geometry.convert(location, from: .global)
                            location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
                            return self.drop(providers: providers, at: location)
                    }

                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
                            .font(self.font(for: emoji))
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
            }
        }
    }

    private func font(for emoji: EmojiArtModel.Emoji) -> Font {
        Font.system(size: emoji.fontSize)
    }

    private func position(for emoji: EmojiArtModel.Emoji, in size: CGSize) -> CGPoint {
        CGPoint(x: emoji.location.x + size.width / 2, y: emoji.location.y + size.height / 2)
    }

    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            print("dropped \(url)")
            self.document.setBackgroundURL(url)
        }

        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }

    private let defaultEmojiSize: CGFloat = 40
}
