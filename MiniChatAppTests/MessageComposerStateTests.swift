//
//  MessageComposerStateTests.swift
//  MessageComposerStateTests
//
//  Created by Bobur Sobirjanov on 9/9/26.
//

import Testing
@testable import MiniChatApp

@MainActor
struct MessageComposerStateTests {
    
    @Test func spacesOnlyCannotBeSent() {
        /// MessageComposerState -> Тип — type. Описывает, из чего состоит черновик и что умеет
        /// composer -> Переменная — variable. Хранит конкретный экземпляр этого типа — твой черновик
        var composer = MessageComposerState()
        composer.text = " "
        
        #expect(composer.canSend == false)
    }
    
    @Test func emptyTextCannotBeSent() {
        let composer = MessageComposerState()
        
        #expect(composer.canSend == false)
    }
    
    @Test func newlinesOnlyCannotBeSent() {
        var composer = MessageComposerState()
        
        composer.text = "\n\n"
        
        #expect(composer.canSend == false)
    }
    
    @Test func tabsOnlyCannotBeSent() {
        var composer = MessageComposerState()
        
        composer.text = "\t\t"
        
        #expect(composer.canSend == false)
    }
    
    @Test func normalTextCanBeSent() {
        var composer = MessageComposerState()
        
        composer.text = "Good day, huh?"
        
        #expect(composer.canSend == true)
    }
    
    @Test func emojiCanBeSent() {
        var composer = MessageComposerState()
        
        composer.text = " 🧃 "
        
        #expect(composer.canSend == true)
    }
    
    @Test func trimmingRemovesSurroundingWhitespace() {
        var composer = MessageComposerState()
        
        composer.text = "  \nHello\n  "
        
        #expect(composer.trimmedText == "Hello")
    }
    
    @Test func trimmingPreservesSpacesBetweenWords() {
        var composer = MessageComposerState()
        
        composer.text = "Hello    World"
        
        #expect(composer.trimmedText == "Hello    World")
    }
    
    @Test func trimmingPreservesInternalLineBreaks() {
        var composer = MessageComposerState()
        
        composer.text = "Hello \nWorld"
        
        #expect(composer.trimmedText == "Hello \nWorld")
    }
    
    @Test func clearingDraftRemovesTextAndDisablesSending() {
        var composer = MessageComposerState()
        
        composer.text = "Hello"
        composer.clear()
         
        #expect(composer.text == "")
        #expect(composer.canSend == false)
    }
}
