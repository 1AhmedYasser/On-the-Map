//
//  LoginTextField.swift
//  On the Map
//
//  Created by Ahmed yasser on 5/14/19.
//  Copyright © 2019 Ahmed yasser. All rights reserved.
//

import UIKit

// A custom class for all text fields
class LoginTextField: UITextField {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // change the corner radius to 5 and tint color to white
        layer.cornerRadius = 5
        tintColor = UIColor.white
    }
    
    // This method returns the rectangle for the text field’s text and then we provide custom inset bounds
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = CGRect(x: bounds.origin.x + 8, y: bounds.origin.y, width: bounds.size.width - 16, height: bounds.size.height)
        return insetBounds
    }
    
    // This method Returns the rectangle in which editable text can be displayed and then we provide custom inset bounds
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        let insetBounds = CGRect(x: bounds.origin.x + 8, y: bounds.origin.y, width: bounds.size.width - 16, height: bounds.size.height)
        return insetBounds
    }
}
