//
//  LoginViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 19.03.25.
//

import UIKit

class LoginViewController: UIViewController {

    var collectionView: UICollectionView!
    
    @IBOutlet weak var entryStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var errorLabel: UILabel?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    deinit {
        print("LoginViewController удален из памяти")
    }


    @IBAction func regBtnClick(_ sender: UIButton) {
        self.switchToRegScreen()
    }
    
    // Удаление RegistrateViewController и переход на экран регистрации
    func switchToRegScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "RegViewController") as? RegViewController {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = mainVC
        }
        
    }
    func switchToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = mainVC
        }
        
    }
    @IBAction func entryBtnClick(_ sender: UIButton) {
        AuthenticationService.shared.loginUser(email: emailTextField.text ?? "", password: passwordTextField.text ?? "") { result in
            switch result {
            case .success(let user):
                self.removeErrorLabel()
                self.switchToMainScreen()
            case .failure(let error):
                self.showErrorLabel(text: error.localizedDescription)
            }
        }

        
               
    }
    func showErrorLabel(text: String) {
        if let existingLabel = errorLabel {
                    // Если лейбл существует, меняем его текст
                    existingLabel.text = text
                } else {
                    // Если лейбл не существует, создаем новый
                    addLabelToView(text: text)
                }
    }
    func addLabelToView(text: String) {
        let label = UILabel()
        label.text = text
        label.textAlignment = .left
        label.textColor = .white
        
        entryStackView.insertArrangedSubview(label, at: 2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: entryStackView.widthAnchor).isActive = true
        label.adjustsFontSizeToFitWidth = true
        errorLabel = label
   }
    
    func removeErrorLabel() {
        // Проверяем, существует ли лейбл
        if let label = errorLabel {
            // Удаляем label из stackView
            label.removeFromSuperview()
            
            // Обнуляем ссылку на лейбл, чтобы объект мог быть освобожден
            errorLabel = nil
        }
    }
}
