//
//  LogoutViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 22.03.25.
//

import UIKit

class LogoutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func logOut(_ sender: UIButton) {
        AuthenticationService.shared.logoutUser(){ result in
            switch result{
            case .success():
                self.switchToLoginScreen()
            case .failure(let error):
                print(error.localizedDescription)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
