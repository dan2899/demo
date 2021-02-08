import Foundation

/// Responsible for updating the detail view textview with text
protocol ResponseBuilder: class {
    func update(response: String)
}

/// Responsible for adding new templates to sections, and seguing to editing a section
protocol NewTemplateDelegate: class {
    func addNewTemplate(toSection section: Int)
}

/// Responsible for updating the main data structure in the main **Boilerplate.swift** file
protocol CategoryDelegate: class {
    func updateTemplates(with templates: [TemplateGroup])
    func updateSection(at int: Int, with section: TemplateGroup)
}


/// Updates the category sort screen with the latest changes to the section
protocol CategoryEditUpdater: class {
    func updateTemplate(at int: Int, with section: TemplateGroup)
}
