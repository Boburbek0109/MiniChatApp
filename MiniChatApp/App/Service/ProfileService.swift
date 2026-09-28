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
        guard snapshot.exists else{
            throw ProfileError.profileNotFound
        }

        return try snapshot.data(as: AppUser.self)
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
    
    func fetchUser(uid: String) async throws -> AppUser {
        let snapshot = try await usersCollection.document(uid).getDocument()
        return try snapshot.data(as: AppUser.self)
    }
    
    func fetchUsers(uid: String) async throws -> [AppUser] {
        let snapshot = try await usersCollection.whereField("uid", isNotEqualTo: uid).getDocuments()
        return try snapshot.documents.map { document in
            try document.data(as: AppUser.self)
        }
    }
}


enum ProfileError: LocalizedError {
    case notLoggedIn
    case profileNotFound
    
    var errorDescription: String? {
        switch self {
        case .notLoggedIn:
            return "User is not logged in"
            
        case .profileNotFound:
            return "Profile not found"
        }
    }
}
