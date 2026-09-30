//
//  SettingViewModel.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import Foundation

@MainActor
@Observable
final class SettingViewModel{
    var newEmail = ""
    var isLoading = false
    var successMessage: String?
    var errorMessage: String?
    var privateProfile = PrivateProfile.init(birthDate: nil, isEmailPublic: false, isBirthdayPublic: false)
    var isPrivacyLoaded = false
    
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
    
    func loadPrivacySettings() async {
        isPrivacyLoaded = false
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            privateProfile = try await profileService.fetchPrivateProfile()
            isPrivacyLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func savePrivacySettings() async {
        if isLoading == true { return }
        isLoading = true
        errorMessage = nil
        successMessage = nil
        defer { isLoading = false }
        
        do {
            try await profileService.savePrivateProfile(profile: privateProfile)
            successMessage = "Privacy setting saved"
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
