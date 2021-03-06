//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 18/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore

    @State private var editMode: EditMode = .inactive

    var body: some View {
        NavigationView {
            List {
                ForEach(store.documents) { document in
                    NavigationLink(destination:
                        EmojiArtDocumentView(document: document)
                        .navigationBarTitle(Text(self.store.name(for: document)))
                    ) {
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.map { self.store.documents[$0] }.forEach { document in self.store.removeDocument(document)}
                }
            }
            .navigationBarTitle(Text(self.store.name))
            .navigationBarItems(leading: Button(action: { self.store.addDocument() },
                                                label: { Image(systemName: "plus").imageScale(.large)}),
                                trailing: EditButton())
                .environment(\.editMode, $editMode)
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
