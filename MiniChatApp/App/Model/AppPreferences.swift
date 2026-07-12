//
//  AppPreferences.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/21/26.
//

import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case dark
    case light
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        case .light: return "Light"
        }
    }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

enum AppTextSize: String, CaseIterable, Identifiable {
    case small
    case medium
    case large
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
        case .small: return "Small"
        case .medium: return "Medium"
        case .large: return "Large"
        }
    }
    
    var dynamicTypeSize: DynamicTypeSize {
        switch self {
        case .small: return .small
        case .medium: return .medium
        case .large: return .large
        }
    }
}
