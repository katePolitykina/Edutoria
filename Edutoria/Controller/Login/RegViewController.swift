//
//  RegViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 19.03.25.
//

import UIKit
class RegViewController: UIViewController {

    @IBOutlet weak var regStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    var errorLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
                view.addGestureRecognizer(tapGesture)

    }
    @objc func hideKeyboard() {
            view.endEditing(true)
        }
    
    deinit {
        print("RegistrateViewController удален из памяти")
    }

    func switchToMainScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "MainViewController") as? MainViewController {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = mainVC
        }
        
    }
    
    
    @IBAction func registerBtnClick(_ sender: UIButton) {
        guard let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty,
              let confirmPassword = confirmPasswordTextField.text, !confirmPassword.isEmpty else {
            self.showErrorLabel(text: "Заполните все поля")
            return
        }
        if password != confirmPassword {
            self.showErrorLabel(text: "Пароли не совпадают")
                return
            }
        AuthenticationService.shared.registerUser(email: email, password: password) { result in
            switch result {
                case .success(let user):
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
        
        regStackView.insertArrangedSubview(label, at: 2)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.widthAnchor.constraint(equalTo: regStackView.widthAnchor).isActive = true
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
    
    
    @IBAction func LoginBtnClick(_ sender: UIButton) {
        self.switchToLoginScreen()
            
    }
    func switchToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = mainVC
        }
    }
    
}
