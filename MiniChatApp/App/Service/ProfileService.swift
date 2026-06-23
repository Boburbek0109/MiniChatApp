//
//  ProfileService.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class ProfileService {
    private let database = Firestore.firestore()
    private let storage = Storage.storage()

    private var usersCollection: CollectionReference {
        database.collection("users")
    }

    func fetchCurrentUserProfile() async throws -> AppUser {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }

        let snapshot = try await usersCollection.document(user.uid).getDocument()

        if let profile = try? snapshot.data(as: AppUser.self) {
            return profile
        } else {
            let newProfile = AppUser(
                uid: user.uid,
                username: "",
                email: user.email ?? "",
                bio: "",
                avatarURL: nil,
                birthDate: nil)

            try usersCollection.document(user.uid).setData(from: newProfile)
            return newProfile
        }
    }

    func updateProfile(_ profile: AppUser) async throws {
        
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ProfileError.notLoggedIn
        }

        try usersCollection.document(uid).setData(from: profile, merge: true)
    }

    func uploadProfileImage(_ imageData: Data) async throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw ProfileError.notLoggedIn
        }

        let ref = storage.reference()
            .child("profile_images")
            .child("\(uid).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)

        let url = try await ref.downloadURL()
        return url.absoluteString
    }

    func updateAuthDisplayNameAndPhoto(name: String, photoURL: String?) async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }

        let request = user.createProfileChangeRequest()
        request.displayName = name

        if let photoURL, let url = URL(string: photoURL) {
            request.photoURL = url
        }

        try await request.commitChanges()
    }

    func sendEmailChangeVerification(to newEmail: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw ProfileError.notLoggedIn
        }

        try await user.sendEmailVerification(beforeUpdatingEmail: newEmail)
    }
}


enum ProfileError: LocalizedError {
    case notLoggedIn
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "User is not logged in"
        }
    }
}
