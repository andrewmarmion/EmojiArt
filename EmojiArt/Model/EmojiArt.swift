//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import Foundation


/// Model
struct EmojiArtModel: Codable {
    var backgroundURL: URL?
    var emojis = [Emoji]()

    struct Emoji: Identifiable, Hashable, Codable, Equatable {
        let text: String
        var x: Int // offset from the center
        var y: Int // offset from the center
        var size: Int
        let id: Int

        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }

        /// Conformance to hashable
        /// using id is enough to identify each Emoji
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        /// Comformance to equatable
        static func ==(lhs: Emoji, rhs: Emoji) -> Bool {
            return lhs.id == rhs.id && lhs.text == rhs.text
        }
    }

    var json: Data? {
        return try? JSONEncoder().encode(self)
    }

    init() {}

    init?(json: Data?) {
        if let data = json, let newEmjoiArt = try? JSONDecoder().decode(EmojiArtModel.self, from: data) {
            self = newEmjoiArt
        } else {
            return nil
        }
    }

    private var uniqueEmojiId = 0

    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
