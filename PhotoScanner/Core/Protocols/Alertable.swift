//
//  Alertable.swift
//  PhotoScanner
//
//  Created by Turker Alan on 23.08.2025.
//

import UIKit

protocol Alertable {
    func showAlert(title: String, message: String)
    func showConfirmationAlert(title: String, message: String, confirmAction: @escaping () -> Void)
    func showErrorAlert(error: Error)
}

extension Alertable where Self: UIViewController {
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showConfirmationAlert(title: String, message: String, confirmAction: @escaping () -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Confirm", style: .destructive) { _ in
            confirmAction()
        })
        
        present(alert, animated: true)
    }
    
    func showErrorAlert(error: Error) {
        showAlert(title: "Error", message: error.localizedDescription)
    }
}
