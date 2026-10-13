//
//  ChatModelTests.swift
//  ChatModelTests
//
//  Created by Bobur Sobirjanov on 10/13/26.
//

import Testing
import Foundation
@testable import MiniChatApp

@MainActor
struct ChatModelTests {

    @Test func missingUnreadCountsReturnsZero() {
        let chat = ChatModel(id: "chat-test", participants: ["user-a", "user-b"], lastSenderId: "user-a", lastMessage: "Hey", updatedAt: Date(), unreadCounts: nil)
        
        let count = chat.unreadCounts(for: "user-a")
        
        #expect(count == 0)
    }

    @Test func emptyUnreadCountsReturnsZero() {
        let chat = ChatModel(id: "chat-test", participants: ["user-a", "user-b"], lastSenderId: "user-a", lastMessage: "Hey", updatedAt: Date(), unreadCounts: [:])
        
        let count = chat.unreadCounts(for: "user-a")
        
        #expect(count == 0)
    }
    
    @Test func unknownUserHasZeroUnreadMessages() {
        let chat = ChatModel(id: "chat-test", participants: ["user-a", "user-b"], lastSenderId: "user-a", lastMessage: "hello world", updatedAt: Date(), unreadCounts: ["user-a": 3])
        
        let count = chat.unreadCounts(for: "user-b")
        
        
        #expect(count == 0)
    }
    
    @Test func unreadCountsAreSeparateForEachUser() {
        let chat = ChatModel(id: "chat-test", participants: ["user-a", "user-b"], lastSenderId: "user-a", lastMessage: "Hello World", updatedAt: Date(), unreadCounts: ["user-a": 3, "user-b": 7])
        
        let firstUserCount = chat.unreadCounts(for: "user-a")
        let secondUserCount = chat.unreadCounts(for: "user-b")
        
        #expect(firstUserCount == 3)
        #expect(secondUserCount == 7)
    }
}
