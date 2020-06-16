//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

/// View Model
class EmojiArtDocument: ObservableObject {

    static let palette: String = "⭐️⛈🍎🌍🥨⚾️"

    @Published private var emojiArt: EmojiArtModel = EmojiArtModel()

    @Published private(set) var backgroundImage: UIImage?

    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }


    // MARK: - Intent(s)

    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }

    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }

    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }

    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL

        fetchBackgroundImageData()
    }

    private func fetchBackgroundImageData() {
        backgroundImage = nil

        // using guard saves the piramid of doom
        guard let url = self.emojiArt.backgroundURL else { return }

        DispatchQueue.global(qos: .userInitiated).async {

            guard let imageData = try? Data(contentsOf: url) else { return }

            guard let image = UIImage(data: imageData) else { return }

            // Set the image on the main thread
            DispatchQueue.main.async {
                if url == self.emojiArt.backgroundURL {
                    self.backgroundImage = image
                }
            }
        }

//        if let url = self.emojiArt.backgroundURL {
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    if let image = UIImage(data: imageData) {
//                        DispatchQueue.main.async {
//                            self.backgroundImage = image
//                        }
//                    }
//                }
//            }
//        }
    }
}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: self.x, y: self.y) }
}
