//
//  UserSearchViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 7/8/26.
//

import Foundation
import FirebaseAuth

@MainActor
@Observable
final class UserSearchViewModel{
    var searchText = ""
    
    private var profileService = ProfileService()
    var users: [AppUser] = []
    
    var errorMessage: String?
    var isLoading = false
    
    func loadUsers() async {
        errorMessage = nil
        isLoading = true
        
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "User is not logged in"
            isLoading = false
            return
        }
        
        do {
            users = try await profileService.fetchUsers(uid: currentUserId)
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    var filteredUsers: [AppUser] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if query.isEmpty {
            return users
        }
        
        return users.filter { user in
            user.username.localizedCaseInsensitiveContains(query) ||
            user.email.localizedCaseInsensitiveContains(query)
        }
    }
}
