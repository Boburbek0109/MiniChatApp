//
//  PrivateProfile.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 9/29/26.
//

import Foundation

struct PrivateProfile: Codable {
    
    var birthDate: Date?
    var isEmailPublic = false
    var isBirthdayPublic = false
}
