//
//  PublicProfile.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 9/29/26.
//

import Foundation

struct PublicProfile: Codable {
    
    let uid: String
    var username: String
    var bio: String
    var avatarURL: String?
    var visibleEmail: String?
    var visibleBirthDate: Date?
}
