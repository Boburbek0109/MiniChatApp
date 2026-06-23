//
//  SettingViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import Foundation

@Observable
final class SettingViewModel{
    var newEmail = ""
    var isLoading = false
    var successMessage: String?
    var errorMessage: String?
    
    private var profileService = ProfileService()
    
    var canSubmitEmail: Bool {
        let email = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        return email.contains("@") && email.contains(".") && !isLoading
    }
    
    func sendEmailChangeVerify(currentEmail: String?) async {
        let email = newEmail.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard canSubmitEmail else { return }
        guard email.caseInsensitiveCompare(currentEmail ?? "") != .orderedSame else {
            errorMessage = "Enter a different email address."
            return }
        isLoading = true
        successMessage = nil
        errorMessage = nil
        defer { isLoading = false }
        do {
            try await profileService.sendEmailChangeVerification(to: email)
            successMessage = "A verification email has been sent to \(email)."
            newEmail = ""
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
