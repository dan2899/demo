import SwiftUI
import UIKit
import MobileCoreServices // For drag & drop functionality

class Boilerplates: UITableViewController, NewTemplateDelegate {
    
    weak var responseBuilder: ResponseBuilder?
    
    private var templates: [TemplateGroup] = []
    
    // Create archiver to handle save/load of templates
    private var archiver = Archiver()
    
    private var buildResponseButton = UIBarButtonItem()
    
    override func viewDidLoad() {
        // Init toolbar items
        toolbarItems = [
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteSelected)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: #imageLiteral(resourceName: "edit").withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector(editSelected))
        ]
        navigationController?.toolbar.tintColor = UIColor(named: "orange")
        navigationController?.toolbar.barTintColor = UIColor(named: "Background") ?? .white
        
        // Drag and drop functionality
        tableView.dragDelegate = self
        tableView.dragInteractionEnabled = true
        
        // Load saved templates
        archiver.load(into: &templates) {
            //self.buildResponse(completion: nil)
            
            // Segue to 'Welcome' screen as user is new to Boilerplate (given that they have no saved data)
            self.performSegue(withIdentifier: "tutorial", sender: nil) // Go to welcome screen
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        addBuildButtonIfNeeded()
    }
    
    /// Adds a 'build' button to trigger response builder if splitview isn't currently displaying the response builder
    func addBuildButtonIfNeeded() {
        // Reference to Split View
        guard let splitView = self.splitViewController else { return }
        
        // Create a 'build response' button
        buildResponseButton = UIBarButtonItem(title: "Build", style: .done, target: self, action: #selector(segueToResponse))
        
        // Check the collapsed property
        if splitView.isCollapsed {
            // Show 'build response' button
            self.navigationItem.rightBarButtonItem = buildResponseButton
        } else {
            // Hide 'build response' button
            self.navigationItem.rightBarButtonItem = nil
        }
        
        var response = ""
        for section in templates where section.selectedTemplateIndex != nil {
            response.append(section.templates?[section.selectedTemplateIndex!].text ?? "")
            response.append("\n\n")
        }
        buildResponseButton.isEnabled = !response.isEmpty
    }
    
    /// Triggers response builder to concatenate selected templates and display the resulting text in the response builder
    /// - Parameter completion: Called once the response text in the response builder has been constructed
    func buildResponse(completion: (() -> Void)?) {
        // Update response string
        var response = ""
        for section in templates where section.selectedTemplateIndex != nil {
            response.append(section.templates?[section.selectedTemplateIndex!].text ?? "")
            response.append("\n\n")
        }
        buildResponseButton.isEnabled = !response.isEmpty
        responseBuilder?.update(response: response)
        completion?()
    }
    
    func selectTemplate(at indexPath: IndexPath) {
        // Deselect all the other cells
        for row in 0..<(templates[indexPath.section].templates?.count ?? 0) where indexPath.row != row {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: indexPath.section)) as? TemplateCell {
                cell.bubbleView.alpha = 0.5
            }
        }
        
        // Select the tapped cell
        if let selectedCell = tableView.cellForRow(at: indexPath) as? TemplateCell {
            // Store selected index in Section
            if templates[indexPath.section].selectedTemplateIndex != indexPath.row {
                templates[indexPath.section].selectedTemplateIndex = indexPath.row
                selectedCell.bubbleView.alpha = 1.0
            } else {
                templates[indexPath.section].selectedTemplateIndex = nil
                selectedCell.bubbleView.alpha = 0.5
            }
        }
        
        // Update response string
        buildResponse(completion: nil)
    }
    
    @objc func dismissEditing() {
        // Add 'edit' button back to navigation bar
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction(_:)))
        navigationItem.leftBarButtonItem = editButton
        tableView.contentInset.bottom = 0.0
        
        // Alter data to reflect changes made to all cells, resign responder and disable textview interactions for each
        for section in 0..<templates.count where templates[section].templates != nil {
            for row in 0..<templates[section].templates!.count {
                let indexPath = IndexPath(row: row, section: section)
                if let cell = tableView.cellForRow(at: indexPath) as? TemplateCell {
                    templates[section].templates![row].text = cell.textView.text
                    cell.textView.resignFirstResponder()
                    cell.textView.isUserInteractionEnabled = false
                    
                    // Remove row & template from tableview if empty
                    if cell.textView.text.isEmpty {
                        templates[section].templates!.remove(at: row)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                }
            }
        }
        buildResponse(completion: nil)
        addBuildButtonIfNeeded()
        archiver.save(templates)
    }
    
    @objc func deleteSelected() {
        let itemsToDelete = tableView.indexPathsForSelectedRows
        // Sorts items into their sections, and then in reverse size order, so items are deleted from bottom up (otherwise the index of each item changes when one before it is deleted).
        for int in 0..<templates.count {
            var itemsInSection = itemsToDelete?.filter({$0.section == int})
            itemsInSection?.sort(by: {$0.row > $1.row})
            for index in itemsInSection ?? [] {
                print("Removing: \(index)")
                templates[int].templates?.remove(at: index.row)
            }
        }
        tableView.deleteRows(at: itemsToDelete ?? [], with: .fade)
        archiver.save(templates)
    }
    
    func addNewTemplate(toSection section: Int) {
        // Insert blank template, checking that it's not nil
        if templates[section].templates == nil {
            templates[section].templates? = []
        }
        templates[section].templates?.append(Template(text: ""))
        
        // Insert blank cell
        let indexPath = IndexPath(row: (templates[section].templates?.count ?? 1) - 1, section: section)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .fade)
        tableView.endUpdates()
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
        // Start editing cell
        if let cell = tableView.cellForRow(at: indexPath) as? TemplateCell {
            cell.textView.isUserInteractionEnabled = true
            cell.textView.becomeFirstResponder()
            cell.textView.tintColor = .white
        }
        
        editAction(self)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissEditing))
        navigationItem.leftBarButtonItem = nil
        archiver.save(templates)
    }
    
    @objc func editSelected() {
        tableView.contentInset.bottom = (self.view.frame.height * 0.5)
        guard let indexOfSelected: IndexPath = tableView.indexPathForSelectedRow else { return }
        if let cell = tableView.cellForRow(at: indexOfSelected) as? TemplateCell {
            cell.textView.isUserInteractionEnabled = true
            cell.textView.becomeFirstResponder()
        }
        editAction(self)
        navigationItem.leftBarButtonItem = nil
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissEditing))
    }
    
    @IBAction func editAction(_ sender: Any) {
        // Disable toolbar buttons since nothing is selected
        toolbarItems?[0].isEnabled = false
        toolbarItems?[2].isEnabled = false
        
        // Set tableview to editing
        navigationController?.setToolbarHidden(tableView.isEditing, animated: true)
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(editAction(_:)))
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editAction(_:)))
        
        let sectionButton = UIBarButtonItem(title: "Categories", style: .plain, target: self, action: #selector(segueToCategories))
        
        if tableView.isEditing {
            navigationItem.leftBarButtonItem = doneButton
            navigationItem.rightBarButtonItem = sectionButton
            let editNotification = Notification(name: NSNotification.Name(rawValue: "EditingActive"))
            NotificationCenter.default.post(editNotification)
        } else {
            navigationItem.leftBarButtonItem = editButton
            navigationItem.rightBarButtonItems = nil
            addBuildButtonIfNeeded()
            let editNotification = Notification(name: NSNotification.Name(rawValue: "EditingInactive"))
            NotificationCenter.default.post(editNotification)
        }
    }
}

// Segue Functions
extension Boilerplates {
    /// Creates Welcome view, and pass in the dismiss functionality to allow the view to be dismissed from an action.
    /// - Returns: `WelcomeView()`
    @IBSegueAction func welcomeSegue(_ coder: NSCoder) -> UIViewController? {
               let rootView = WelcomeView(dismiss: {self.dismiss(animated: true, completion: nil)})
               return UIHostingController(coder: coder, rootView: rootView)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "categories" {
            if let destVC = segue.destination as? CategorySort {
                destVC.templates = templates
                destVC.categoryDelegate = self
            }
        }
    }
    
    @objc func segueToResponse() {
        buildResponse {
            guard let detailViewController = self.responseBuilder as? Response else { return }
            self.splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
    
    @objc func segueToCategories() {
        editAction(self)
        self.performSegue(withIdentifier: "categories", sender: nil)
    }
    
}

// Tableview functions
extension Boilerplates {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.isEditing {
            // Enable/Disable delete & edit buttons on selection
            toolbarItems?[0].isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0 > 0)
            toolbarItems?[2].isEnabled = (tableView.indexPathsForSelectedRows?.count == 1)
        } else {
            selectTemplate(at: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        // Enable/Disable delete & edit buttons on deselection
        toolbarItems?[0].isEnabled = (tableView.indexPathsForSelectedRows?.count ?? 0 > 0)
        toolbarItems?[2].isEnabled = (tableView.indexPathsForSelectedRows?.count == 1)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return templates.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return templates[section].templates?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "templateCell", for: indexPath) as? TemplateCell else {
            return UITableViewCell()
        }
        cell.multipleSelectionBackgroundView = nil
        cell.initTemplate(textDelegate: self, colour: UIColor(named: templates[indexPath.section].colour ?? "orange") ?? .orange, text: templates[indexPath.section].templates?[indexPath.row].text)
        
        cell.bubbleView.alpha = (indexPath.row == templates[indexPath.section].selectedTemplateIndex) ? 1.0 : 0.5
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = HeaderView()
        header.title.text = templates[section].title?.localizedUppercase
        if tableView.isEditing {
            header.buttonBar.alpha = 1.0
        } else {
            header.buttonBar.alpha = 0.0
        }
        header.buttonBar.tag = section
        header.newTemplateDelegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
}

extension Boilerplates: UITextViewDelegate { // Textfield delegate for cells
    func textViewDidChange(_ textView: UITextView) {
        // Calculate if the text view will change height, then only force the table to update if it does.  Also disable animations to prevent "jankiness".
        let startHeight = textView.frame.size.height
        let calcHeight = textView.sizeThatFits(textView.frame.size).height  //iOS 8+ only
        if startHeight != calcHeight {
            UIView.setAnimationsEnabled(false) // Disable animations
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            UIView.setAnimationsEnabled(true)  // Re-enable animations.
        }
    }
    
}

extension Boilerplates: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        // Stop drag & drop if editing is in progress
        if tableView.isEditing {
            return []
        }
        
        var string = templates[indexPath.section].templates?[indexPath.row].text
        string?.append(" ")
        guard let data = string?.data(using: .utf8) else {
            return []
        }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, dragPreviewParametersForRowAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        guard let cell = tableView.cellForRow(at: indexPath) as? TemplateCell else {
            return nil
        }
        let previewParameters = UIDragPreviewParameters()
        let path = UIBezierPath(roundedRect: cell.bubbleView.frame, cornerRadius: 16.0)
        previewParameters.visiblePath = path
        previewParameters.backgroundColor = .clear
        return previewParameters
    }
    
}

extension Boilerplates: CategoryDelegate {
    func updateSection(at int: Int, with section: TemplateGroup) {
        templates[int] = section
        tableView.reloadData()
        archiver.save(templates)
    }
    
    func updateTemplates(with templates: [TemplateGroup]) {
        self.templates = templates
        tableView.reloadData()
        archiver.save(templates)
    }
    
}
