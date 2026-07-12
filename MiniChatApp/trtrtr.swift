//
//  trtrtr.swift
//  MiniChatApp
//
//  Created by Bobur Sobirjanov on 6/28/26.
//

import SwiftUI

struct Trigger_Button: View{
    
    @AppStorage("myBool") var myBool = false
    @AppStorage("myInt") var myInt = 23
    @AppStorage("myDoubt") var myDoubt = 1.99
    @AppStorage("myString") var myString = "Hello World!"
    @AppStorage("myUrl") var myUrl = URL(string: "https://www.google.com")!
    @AppStorage("myData") var myData = Data ("Hello,wy".utf8)
    
    @AppStorage("darkbackground") var darkBackground = false
    
    @State private var showButtons = false
    
    var body: some View{
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 20) {
                Text("Triggers").font(.largeTitle)
                Text("Buttons").foregroundStyle(.gray)
                
                Text ("Stored in AppStorage").bold()
                Text ("\(myBool.description)")
                Text ("\(myInt)")
                Text ("\(myDoubt)")
                Text ("\(myString)")
                Link ("\(myUrl)", destination: myUrl).font(.title)
                Text ("\(String (decoding: myData, as: UTF8.self))")

                Toggle (isOn: $darkBackground, label: {
                Text("Use Dark Background?")
                })
                .padding()
                
                Spacer()
            }
            .font(.title)
            .preferredColorScheme (darkBackground ? .dark : .light)
            
            Group {
                Button(action: { showButtons.toggle() }){
                    Image(systemName: "bag.badge.plus")
                        .padding(24)
                        .rotationEffect(Angle.degrees(showButtons ? 0 : -90))
                }
                .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
                .opacity(showButtons ? 1 : 0)
                .offset(x: 0, y: showButtons ? -150 : 0)
                
                Button(action: { showButtons.toggle() }){
                    Image(systemName: "gauge.badge.plus")
                        .padding(24)
                        .rotationEffect(Angle.degrees(showButtons ? 0 : 90))
                }
                .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
                .offset(x: showButtons ? -110 : 0, y: showButtons ? -110 : 0)
                .opacity(showButtons ? 1 : 0)
                
                Button(action: { showButtons.toggle() }) {
                    Image(systemName: "calendar.badge.plus")
                        .padding(24)
                        .rotationEffect(Angle.degrees(showButtons ? 0 : 90))
                }
                .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
                .offset(x: showButtons ? -150 : 0, y: 0)
                .opacity(showButtons ? 1 : 0)
                
                Button(action: {showButtons.toggle()} ) {
                    Image(systemName: "plus")
                        .padding(24)
                        .rotationEffect(Angle.degrees(showButtons ? 45 : 0))
                }
                .background(Circle().fill(Color.green).shadow(radius: 8, x: 4, y: 4))
            }
            .padding(.trailing, -200)
            .tint(.white)
            .animation(.default, value: showButtons)
        }
        .font(.title)
    }
}


#Preview {
    Trigger_Button()
}
