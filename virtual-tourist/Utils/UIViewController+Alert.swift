//
//  UIViewController+Alert.swift
//  virtual-tourist
//
//  Created by Fabrício Silva Carvalhal on 11/07/21.
//

import UIKit

extension UIViewController {
    
    func showErrorAlert(message: String, title: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
