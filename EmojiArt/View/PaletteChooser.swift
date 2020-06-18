//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 18/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    @Binding var chosenPalette: String
    @State private var showPaletteEditor: Bool = false

    var body: some View {
        HStack {

            Stepper(onIncrement: stepperOnIncrement,
                    onDecrement: stepperOnDecrement,
                    label: { Text("Choose Palette") })
                .labelsHidden() // This hides the label but gives us accessibility

            Text(document.paletteNames[self.chosenPalette] ?? "")

            Image(systemName: "keyboard")
                .imageScale(.large)
                .onTapGesture { self.showPaletteEditor.toggle() }
                .popover(isPresented: $showPaletteEditor) {
                    PaletteEditor(chosenPalette: self.$chosenPalette,
                                  isShowing: self.$showPaletteEditor)
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
    }

    private func stepperOnIncrement() {
        self.chosenPalette = self.document.palette(after: self.chosenPalette)
    }

    private func stepperOnDecrement() {
        self.chosenPalette = self.document.palette(before: self.chosenPalette)
    }
}



struct PalletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: .constant(""))
    }
}
