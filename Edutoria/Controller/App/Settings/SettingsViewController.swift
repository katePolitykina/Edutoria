//
//  SettingsViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 30.03.25.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func DeleteAccountButtonClicked(_ sender: UIButton) {

        let alertController = UIAlertController(title: "Удалить аккаунт", message: "Введите ваш пароль для подтверждения удаления аккаунта.", preferredStyle: .alert)
        
        // Добавляем поле для ввода пароля
        alertController.addTextField { (textField) in
            textField.isSecureTextEntry = true
            textField.placeholder = "Пароль"
        }
        
        // Кнопка отмены
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        
        // Кнопка подтверждения
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Получаем введенный пароль
            if let password = alertController.textFields?.first?.text {
                self.deleteUser(password: password)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        
        // Показываем алерт
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deleteUser(password: String) {
        AuthenticationService.shared.deleteUser(password: password) { result in
            switch result {
            case .success():
                self.switchToLoginScreen()
            case .failure(let error):
                // Обработали ошибку при удалении
                self.showError(error)
            }
        }
    }
    func switchToLoginScreen() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = mainVC
        }
    }
    
    
    func showDeletionSuccess() {
        let successAlert = UIAlertController(title: "Успешно удалено", message: "Ваш аккаунт был удален.", preferredStyle: .alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(successAlert, animated: true, completion: nil)
    }
    
    func showError(_ error: AuthenticationError) {
        let errorAlert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(errorAlert, animated: true, completion: nil)
    }
}
