//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentView: View {

    typealias Emoji = EmojiArtModel.Emoji

    private struct AlertIdentifier: Identifiable {
        var id: Choice

        enum Choice {
            case explain
            case confirm
        }
    }

    @Environment(\.horizontalSizeClass) var sizeClass

    //MARK: - Properties
    @ObservedObject var document: EmojiArtDocument

    @State private var chosenPalette: String = ""

    @GestureState private var gestureZoomScale: CGFloat = 1.0
    @GestureState private var gesturePanOffSet: CGSize = .zero

    @State private var selectedEmojis = Set<Emoji>()
    @GestureState private var gestureSelectedEmoji: (offset: CGSize, emoji: Emoji?) = (.zero, nil)

    @State private var showPasteAlert: AlertIdentifier?

    @State private var explainBackgroundPaste: Bool = false
    @State private var confirmBackgroundPaste: Bool = false

    private let defaultEmojiSize: CGFloat = 40

    init(document: EmojiArtDocument) {
        self.document = document
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
    }

    // MARK: - View
    var body: some View {
        VStack {

            HVStack {
                PaletteChooser(document: self.document, chosenPalette: self.$chosenPalette)
                // Emoji Selector
                ScrollView(.horizontal, showsIndicators: true) {
                    HStack {
                        ForEach(self.chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: self.defaultEmojiSize))
                                .onDrag {
                                    return NSItemProvider(object: emoji as NSString) // from ObjC we need it to be NSString
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)

            // Canvas
            GeometryReader { geometry in
                ZStack {
                    Color.white
                        .overlay(OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size).exclusively(before: self.deselectAllEmojis()))


                    if self.isLoading {
                        Image(systemName: "hourglass")
                            .imageScale(.large)
                            .spinning()

                    } else {
                        // Add the emojis to the canvas
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .font(animatableWithSize: emoji.fontSize * self.emojiZoomScale(for: emoji))
                                .showOutline(showOutline: self.isEmojiSelected(emoji))
                                .position(self.position(for: emoji, in: geometry.size))
                                .gesture(self.dragSelected(emoji: emoji))
                                .gesture(self.select(emoji: emoji))

                        }
                    }
                }
                .clipped()
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onReceive(self.document.$backgroundImage, perform: { image in self.zoomToFit(image, in: geometry.size) })
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    let location = self.calculateLocation(for: geometry, at: location)
                    return self.drop(providers: providers, at: location)

                }
                .navigationBarItems(trailing:
                    Button(action: self.pasteURL,
                           label: { Image(systemName: "doc.on.clipboard").imageScale(.large)}
                    )
                )
            }
            .zIndex(-1)
        }
            // Use an enum for showing the alerts
            .alert(item: self.$showPasteAlert) { alert -> Alert in
                switch alert.id {
                case .explain:
                    return Alert(
                        title: Text("Paste Background"),
                        message: Text("Copy the URL of an image to the clipboard and touch this button to make it the background of the document."),
                        dismissButton: .default(Text("OK")))

                case .confirm:
                    return Alert(
                        title: Text("Paste Background"),
                        message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")"),
                        primaryButton: .default(Text("OK"), action: {
                            self.document.backgroundURL = UIPasteboard.general.url
                        }),
                        secondaryButton: .cancel(Text("Cancel"))
                    )
                }
        }
    }

    //MARK: - Methods

    private func calculateLocation(for geometry: GeometryProxy, at location: CGPoint) -> CGPoint {
        // Due to the EmojiArtDocumentChooser being visible the x coordinate is in the wrong coordinate system
        // by ignoring the effects to x, we can position it correctly on the screen.
        // var location = geometry.convert(location, from: .global)
        var location = CGPoint(x: location.x, y: geometry.convert(location, from: .global).y)
        location = CGPoint(x: location.x - geometry.size.width / 2, y: location.y - geometry.size.height / 2)
        location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
        location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
        return location
    }

    private func pasteURL() {
        if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
            self.showPasteAlert = AlertIdentifier(id: .confirm)
        } else {
            self.showPasteAlert = AlertIdentifier(id: .explain)
        }
    }

    //MARK: - Loading

    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }

    //MARK: - Selection

    /// Checks to see if the emoji has been selected
    /// - Parameter emoji: The Emoji we are checking
    /// - Returns: A boolean describing its selected state
    private func isEmojiSelected(_ emoji: Emoji) -> Bool {
        self.selectedEmojis.contains(emoji)
    }

    /// A computed property that states whether
    /// we have any emojis selected
    private var emojiSelected: Bool {
        !self.selectedEmojis.isEmpty
    }

    /// A gesture that adds an emojis to the selectedEmojis set
    /// - Parameter emoji: The emoji that we wish to add
    /// - Returns: A gesture that adds the emoji
    private func select(emoji: Emoji) -> some Gesture {
        TapGesture(count: 1).onEnded { _ in
            self.selectedEmojis.toggle(emoji)
        }
    }


    /// A gesture that removes all the emojis from the selectedEmojis set
    /// - Returns: A gesture that removes all the emojis from the selectedEmojis set
    private func deselectAllEmojis() -> some Gesture {
        TapGesture(count: 1).onEnded { _ in
            self.selectedEmojis.removeAll()
        }
    }

    //MARK: Dragging Emoji

    /// Drags selected and unselected emoji
    /// - Parameter emoji: The Emoji we are dragging
    /// - Returns: A DragGesture that moves the emoji
    private func dragSelected(emoji: Emoji) -> some Gesture {
        let emojiSelected = self.isEmojiSelected(emoji)
        let currentEmoji =  emojiSelected ? nil : emoji
        return DragGesture()
            .updating($gestureSelectedEmoji) { latestValue, gestureSelectedEmoji, transition in
                let translation = latestValue.translation
                gestureSelectedEmoji = (translation, currentEmoji)
        }
        .onEnded { lastValue in
            let updatedTranslation = lastValue.translation / self.zoomScale
            if emojiSelected {
                for selectedEmoji in self.selectedEmojis {
                    self.document.moveEmoji(selectedEmoji, by: updatedTranslation)
                }
            } else {
                self.document.moveEmoji(emoji, by: updatedTranslation)
            }
        }
    }

    // MARK: - Zoom

    /// Calculates the zoom scale for the emoji
    /// - Parameter emoji: The emoji that we want the zoom scale of
    /// - Returns: The zoom scale
    private func emojiZoomScale(for emoji: Emoji) -> CGFloat {
        isEmojiSelected(emoji) ? document.steadyStateZoomScale * gestureZoomScale : zoomScale
    }

    /// The zoom scale of the canvas
    ///
    /// We only want to enable zooming of the canvas when no emoji are selected
    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * (emojiSelected ? 1 : gestureZoomScale)
    }

    /// A Magnification Gesture that scales the canvas
    /// if we have selected emoji, scales them while leaving the canvas static
    /// - Returns: A Magnification Gesture
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
        }
        .onEnded { finalGestureScale in
            if self.emojiSelected {
                for emoji in self.selectedEmojis {
                    self.document.scaleEmoji(emoji, by: finalGestureScale)
                }
            } else {
                self.document.steadyStateZoomScale *= finalGestureScale
            }
        }
    }

    /// A TapGesture that zooms the background image
    /// - Parameter size: the size that the image should fit in
    /// - Returns: A TapGesture
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2).onEnded {
            withAnimation {
                self.zoomToFit(self.document.backgroundImage, in: size)
            }
        }
    }

    /// Takes an image and fits it to the canvas
    /// - Parameters:
    ///   - image: The image we wish to fit
    ///   - size: the size of the canvas
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }


    // MARK: - Panning

    /// The offset that we pan by
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffSet) * zoomScale
    }


    /// A DragGesture that pans the canvas
    /// - Returns: A DragGesture
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffSet) { latestDragGestureValue, gesturePanOffSet, transaction in
                gesturePanOffSet = latestDragGestureValue.translation / self.zoomScale
        }
        .onEnded { finalDragGestureValue in
            self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
        }
    }


    //MARK: - Emoji Helpers

    /// Calculates the position of the Emoji on the canvas
    /// - Parameters:
    ///   - emoji: The Emoji we wish to position
    ///   - size: the size of the canvas
    /// - Returns: A CGPoint of the position of the Emoji
    private func position(for emoji: Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * self.zoomScale, y: location.y * self.zoomScale)
        location = CGPoint(x: location.x + size.width / 2, y: location.y + size.height / 2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        let (offset, selectedEmoji) = gestureSelectedEmoji
        if selectedEmoji == emoji || (selectedEmoji == nil && isEmojiSelected(emoji)) {
            location = CGPoint(x: location.x + offset.width, y: location.y + offset.height)
        }
        return location
    }

    //MARK: - Drop

    /// Handle dropping emoji and images on to the canvas.
    /// - Parameters:
    ///   - providers: An array of NSItemProviders
    ///   - location: The location on screen where the item was dropped
    /// - Returns: A boolean describing if the drop was successful
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }

        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: self.defaultEmojiSize)
            }
        }
        return found
    }
}
