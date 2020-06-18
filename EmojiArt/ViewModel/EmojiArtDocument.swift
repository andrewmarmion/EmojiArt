//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI
import Combine

/// View Model
class EmojiArtDocument: ObservableObject, Identifiable, Hashable, Equatable {

    let id: UUID

    static let palette: String = "⭐️⛈🍎🌍🥨⚾️"
    private static let untitled = "EmojiArtDocument.Untitled"

    @Published var emojiArt: EmojiArtModel
    @Published private(set) var backgroundImage: UIImage?
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero

    var emojis: [EmojiArtModel.Emoji] { emojiArt.emojis }

    private var autosaveCancellable: AnyCancellable?
    private var fetchImageCancellable: AnyCancellable?

    init(id: UUID? = nil) {
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
        emojiArt = EmojiArtModel(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArtModel()
        autosaveCancellable = $emojiArt.sink { emojiArt in
            print("\(emojiArt.json?.utf8 ?? "nil")")
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }

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

    var backgroundURL: URL? {
        get { emojiArt.backgroundURL }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }

    private func fetchBackgroundImageData() {
        backgroundImage = nil

        // using guard saves the piramid of doom
        guard let url = self.emojiArt.backgroundURL else { return }

        fetchImageCancellable?.cancel()

        fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { data, response in UIImage(data: data) }
            .receive(on: RunLoop.main) // Current theory is that RunLoop.main is better than DispatchQueue.main
            .replaceError(with: nil)
            .assign(to: \.backgroundImage, on: self) // Currently assign has a memory leak, is this the best way to do this?

    }

    // Conformance to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conformance to Equatable
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        lhs.id == rhs.id
    }

}

extension EmojiArtModel.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: self.x, y: self.y) }
}
