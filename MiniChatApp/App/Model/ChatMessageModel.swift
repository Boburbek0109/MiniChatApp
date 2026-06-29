//
//  ChatMessageModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/20/26.
//

import FirebaseAuth
import FirebaseFirestore

struct ChatMessageModel: Codable, Identifiable {
    @DocumentID var id: String?

    let senderId: String
    let receiverId: String
    let senderEmail: String?
    let messages: String
    let createdAt: Date

    var isFromCurrentUser: Bool {
        senderId == Auth.auth().currentUser?.uid
    }
}
