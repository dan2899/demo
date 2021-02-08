//
//  Copyright © 2019 Dan McDonald. All rights reserved.
//

import Foundation

/// Handles the storing and retriving of templates from `UserDefaults`, which is synced with iCloud
class Archiver {
    
    /// Archives templates and stores them
    func save(_ rootObject: Any) {
        let saveData = NSKeyedArchiver.archivedData(withRootObject: rootObject)
        UserDefaults.standard.removeObject(forKey: "responses")
        UserDefaults.standard.set(saveData, forKey: "responses")
    }
    
    /// Fetches templates if available, otherwise loads the default template selection
    func load(into templates: inout [TemplateGroup], onFirstCompletion: (() -> Void)? = nil) {
        if let localData = UserDefaults.standard.data(forKey: "responses"), let savedResponses = NSKeyedUnarchiver.unarchiveObject(with: localData) as? [TemplateGroup] {
            templates = savedResponses
        } else {
            // Default templates (which act as tutorial)
            templates = [
                TemplateGroup(title: "Greeting", colour: "red", templates: [
                    Template(text: "Hey,"),
                    Template(text: "Hi there,"),
                    Template(text: "Hello,")
                    ], selected: 0),
                TemplateGroup(title: "Lead in", colour: "yellow", templates: [
                    Template(text: "Warm welcome to Boilerplate!"),
                    Template(text: "This is Boilerplate, a warm welcome to the app!")
                    ], selected: 0),
                TemplateGroup(title: "How to use", colour: "blue", templates: [
                    Template(text: "Tap on these templates to select them and build your message. Edit any of these by tapping 'edit'."),
                    Template(text: "Select any template by tapping and then build your message. These templates can be edited by tapping 'edit'"),
                    Template(text: "Just try tapping.")
                    ], selected: 1),
                TemplateGroup(title: "Editing", colour: "purple", templates: [
                    Template(text: "To edit the categories, you can simply tap 'categories' whilst in Edit Mode, and add, delete, or modify any of the categories."),
                    Template(text: "Editing the categories can be done by tapping the 'categories' button, whilst in Edit Mode. From there, you can add, delete, or modify any of the categories.")
                    ], selected: 0),
                TemplateGroup(title: "Structure", colour: "pink", templates: [
                    Template(text: "These categories could have variations of the same thing, with little changes depending on who you're talking to."),
                    Template(text: "On the otherhand, they could say something completly different in it's place! It's entirely up to you.")
                    ], selected: 0)
            ]
            
            // Call completion
            onFirstCompletion?()
        }
    }
    
}
