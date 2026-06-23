//
//  ChatMessageModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/20/26.
//

import FirebaseAuth
import FirebaseFirestore

struct ChatMessage: Codable, Identifiable {
    @DocumentID var id: String?

    let text: String
    let senderId: String
    let senderEmail: String?
    let createdAt: Date

    var isFromCurrentUser: Bool {
        senderId == Auth.auth().currentUser?.uid
    }
}
