import UIKit

/// The logic *and* UI of the custom header view with toolbar.
///
/// It contains the UI because for some reason, when using a **UITableViewCell** as a Header/Footer view, it can spontaniously disappear when the tableview is edited. This means that I had to generate all the UI programatically, as well as the logic like usual. Even constraints are done programatically - please add me to your daily thoughts and prayers.
///
/// Noted Inefficiencies: It removes and adds all constraints every time it is drawn
///
/// Instantiate as **HeaderView()** and it'll handle all the rest.
class HeaderView: UITableViewHeaderFooterView {
    
    weak var newTemplateDelegate: NewTemplateDelegate?
    
    let title = UILabel()
    let buttonBar = UIToolbar()

    // Only override draw() if you perform custom drawing.
    override func draw(_ rect: CGRect) {
        
        self.contentView.backgroundColor = UIColor(named: "Background") ?? .white
        
        NotificationCenter.default.addObserver(self, selector: #selector(editingActive), name: NSNotification.Name(rawValue: "EditingActive"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(editingInactive), name: NSNotification.Name(rawValue: "EditingInactive"), object: nil)
        
        let lightishGrey = UIColor(named: "Grey") ?? UIColor(white: 0.8, alpha: 1.0)
        
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textColor = lightishGrey
        let fontSize = UIFont.preferredFont(forTextStyle: .caption1).pointSize
        title.font = UIFont.systemFont(ofSize: fontSize, weight: .medium)
        self.addSubview(title)
        
        buttonBar.translatesAutoresizingMaskIntoConstraints = false
        buttonBar.tintColor = lightishGrey
        buttonBar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        buttonBar.setShadowImage(UIImage(), forToolbarPosition: .any)
        
        buttonBar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newTemplateAction))
        ]
        self.addSubview(buttonBar)
        
        let safeInset = self.safeAreaInsets.left + 16
        
        // Prepare yourself for a fucking nightmare
        
        // Remove all existing constrains before applying current ones
        self.removeConstraints(self.constraints)
        self.addConstraints([
            
            // Self leading to title leading
            NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: title, attribute: .leading, multiplier: 1.0, constant: -safeInset),
            
            // title top & bottom
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: title, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: title, attribute: .bottom, multiplier: 1.0, constant: -0.0),
            
            // title trailing to bar leading
            NSLayoutConstraint(item: title, attribute: .trailing, relatedBy: .greaterThanOrEqual, toItem: buttonBar, attribute: .leading, multiplier: 1.0, constant: -8.0),
            
            // bar top & bottom
            NSLayoutConstraint(item: self, attribute: .top, relatedBy: .greaterThanOrEqual, toItem: buttonBar, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: buttonBar, attribute: .bottom, multiplier: 1.0, constant: -0.0),
            
            // bar trailing to self trailing
            NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: buttonBar, attribute: .trailing, multiplier: 1.0, constant: 0.0)
            ])
    }
    
    @objc func newTemplateAction() {
        newTemplateDelegate?.addNewTemplate(toSection: buttonBar.tag)
    }
    
    @objc func editingActive() {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.alpha = 1.0
        }
    }
    
    @objc func editingInactive() {
        UIView.animate(withDuration: 0.3) {
            self.buttonBar.alpha = 0.0
        }
    }

}
