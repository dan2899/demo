//
//  Copyright © 2020 Dan McDonald. All rights reserved.
//

import SwiftUI

struct WelcomeView: View {
    
    var dismiss: (() -> Void)?
    
    var body: some View {
        ScrollView(.vertical) {
            VStack(alignment: .leading, spacing: 32) {
                Text("Welcome to Boilerplate")
                    .font(.largeTitle)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.leading)
                Section {
                    Paragraph(systemImageName: "person.2.fill", colour: .yellow, title: "Pre-written messages", paragraph: "Create a bank of personal, pre-written, and reusable templates to draw from and build your message.")
                    
                    Paragraph(systemImageName: "rectangle.stack.badge.plus.fill", colour: .orange, title: "Quick Creation", paragraph: "Select the templates you want to use, and hit 'build' to generate a rough draft of the messages using those templates.")
                    
                    Paragraph(systemImageName: "pencil.circle.fill", colour: .red, title: "Easy Editing", paragraph: "Edit any template by going into Edit Mode, or customise the categories under the 'categories' button.")
                    
                    Paragraph(systemImageName: "hand.draw.fill", colour: .purple, title: "Drag & Drop", paragraph: "Drag templates into any text window to quickly compose a message.")
                }.padding(.vertical, 10)
                
                HStack {
                    Spacer(minLength: 0)
                    Button(action: dismiss!, label: {
                        Text("Get Started")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(idealWidth: 300, maxWidth: 300)
                            .padding()
                            .background(Color("orange"))
                            .cornerRadius(3.0)
                    })
                    Spacer(minLength: 0)
                }
            }.padding(.vertical, 40)
            .padding(.horizontal, 20)
        }
    }
}

/// Paragraph for the 'Welcome' screen. Includes system image, tint, title, and paragraph text.
struct Paragraph: View {
    var systemImageName: String
    var colour: Color
    var title: String
    var paragraph: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // SFSymbol
            Image(systemName: systemImageName).resizable().aspectRatio(contentMode: .fit).frame(height: 40, alignment: .center).foregroundColor(colour)
            
            // Title Text
            Text(title)
                .font(Font.system(.headline, design: .rounded))
            
            // Paragraph Text
            Text(paragraph)
                .font(Font.system(.body, design: .rounded))
                .multilineTextAlignment(.leading)
        }
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
