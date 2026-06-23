//
//  SettingsView.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/15/26.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("appTextSize") private var appTextSize: AppTextSize = .medium
    
    var body: some View {
        Form{
            Section("Text Size"){
                Picker("Text Size", selection: $appTextSize){
                    ForEach(AppTextSize.allCases){ size in
                        Text(size.title)
                            .tag(size)
                    }
                }
            }
            
        }
        .navigationTitle("Setting")
    }
}


#Preview {
    SettingsView()
}
