//
//  ChatModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/1/26.
//

import Foundation

struct ChatModel: Codable, Identifiable {
    
    let id: String
    let participants: [String]
    let lastSenderId: String
    let lastMessage: String
    let updatedAt: Date
}
