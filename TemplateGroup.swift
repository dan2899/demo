import Foundation
import UIKit

/// Used to store a series of Templates
class TemplateGroup: NSObject, NSCoding {
    
    var title: String? // Name of the section.
    var colour: String? // Colour of the bubble and highlighting, stored as string and matched with colour of that name
    var templates: [Template]? // Array of templates for that section.
    var selectedTemplateIndex: Int? // Selected template's index, which is template that will be used.
    
    // Optional init parameters
    init(title: String? = nil, colour: String? = "orange", templates: [Template]? = [], selected: Int? = nil) {
        self.title = title
        self.colour = colour
        self.templates = templates
        self.selectedTemplateIndex = selected
    }
    
    // Encode into Data for storage (iCloud, Device, etc)
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: "title")
        aCoder.encode(colour, forKey: "colour")
        aCoder.encode(templates, forKey: "templates")
    }
    
    // Decode from Data from storage (iCloud, Device, etc)
    required init?(coder aDecoder: NSCoder) {
        self.title = aDecoder.decodeObject(forKey: "title") as? String ?? "Error Decoding"
        self.colour = aDecoder.decodeObject(forKey: "colour") as? String ?? "orange"
        self.templates = aDecoder.decodeObject(forKey: "templates") as? [Template] ?? nil
        self.selectedTemplateIndex = nil
    }
}
