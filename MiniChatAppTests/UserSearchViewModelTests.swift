//
//  UserSearchViewModelTests.swift
//  UserSearchViewModelTests
//
//  Created by Bobur Sobirjanov on 10/13/26.
//

import Testing
@testable import MiniChatApp

@MainActor
struct UserSearchViewModelTests {

    @Test func emptyQueryReturnsNoUsers() {
        let searchVM = UserSearchViewModel()
        let user = AppUser(uid: "user-a", username: "Bobur", email: "bobur@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [user]
        
        searchVM.searchText = ""
        
        #expect(searchVM.filteredUsers.isEmpty)
    }
    
    @Test func whitespaceQueryReturnsNoUsers() {
        let searchVM = UserSearchViewModel()
        let user = AppUser(uid: "user-a", username: "Bobur", email: "bobur@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [user]
        
        searchVM.searchText = "   "
        
        #expect(searchVM.filteredUsers.isEmpty)
    }

    @Test func searchFindsPartOfUsername() {
        let searchVM = UserSearchViewModel()
        let userA = AppUser(uid: "user-a", username: "Bobur", email: "first@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        let userB = AppUser(uid: "user-b", username: "Alex", email: "alex@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [userA, userB]
        
        searchVM.searchText = "obu"
        
        #expect(searchVM.filteredUsers.count == 1)
        #expect(searchVM.filteredUsers.first?.uid == "user-a")
    }
    
    @Test func searchIgnoresLetterCase() {
        let searchVM = UserSearchViewModel()
        let userA = AppUser(uid: "user-a", username: "Bobur", email: "first@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        let userB = AppUser(uid: "user-b", username: "Alex", email: "alex@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [userA, userB]
        
        searchVM.searchText = "bObUr"
        
        #expect(searchVM.filteredUsers.count == 1)
        #expect(searchVM.filteredUsers.first?.uid == "user-a")
    }
    
    @Test func searchFindsMatchingEmail() {
        let searchVM = UserSearchViewModel()
        let userA = AppUser(uid: "user-a", username: "Bobur", email: "first@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        let userB = AppUser(uid: "user-b", username: "Alex", email: "alex@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [userA, userB]
        
        searchVM.searchText = "first"
        
        #expect(searchVM.filteredUsers.count == 1)
        #expect(searchVM.filteredUsers.first?.uid == "user-a")
    }
    
    @Test func unmatchedQueryReturnsNoUsers() {
        let searchVM = UserSearchViewModel()
        let userA = AppUser(uid: "user-a", username: "Bobur", email: "first@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        let userB = AppUser(uid: "user-b", username: "Alex", email: "alex@gmail.com", bio: "", avatarURL: nil, birthDate: nil)
        searchVM.users = [userA, userB]
        
        searchVM.searchText = "zzzz"
        
        #expect(searchVM.filteredUsers.isEmpty)
    }
    
}
