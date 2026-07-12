//
//  MessageComposerState.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/9/26.
//

import UIKit

struct MessageComposerState {
    var text = ""
    var selectedImage: UIImage?

    var canSend: Bool {
        !trimmedText.isEmpty || selectedImage != nil
    }
    
    var trimmedText: String{
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    mutating func clear() {
        text = ""
        selectedImage = nil
    }
}
