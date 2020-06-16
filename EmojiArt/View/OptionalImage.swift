//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by Andrew Marmion on 16/06/2020.
//  Copyright © 2020 Andrew Marmion. All rights reserved.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?

    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}

struct OptionalImage_Previews: PreviewProvider {
    static var previews: some View {
        OptionalImage()
    }
}
