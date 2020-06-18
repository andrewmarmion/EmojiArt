//
//  PaletteEditor.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 18/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct PaletteEditor: View {

    @EnvironmentObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""

    var height: CGFloat {
        CGFloat((self.chosenPalette.count - 1) / 6 * 70 +  70)
    }

    private let fontSize: CGFloat = 40

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                        }, label: { Text("Done") }).padding()
                }
            }
            Divider()
            Form {
                Section {
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    }).padding()

                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    }).padding()
                }

                Section(header: Text("Remove Emoji")) {
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                        }
                    }
                    .frame(height: self.height)
                }
            }
        }
        .onAppear {
            self.paletteName = self.document.paletteNames[self.chosenPalette] ?? ""
        }
    }
}

struct PaletteEditor_Previews: PreviewProvider {
    static var previews: some View {
        PaletteEditor(chosenPalette: .constant(""), isShowing: .constant(true))
    }
}
