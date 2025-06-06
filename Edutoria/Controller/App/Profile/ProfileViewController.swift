import UIKit

class ProfileViewController: UIViewController {
    
    private var userId: String = ""
    private var userEmail: String = ""
    private var currentProfile: UserProfile?
    
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let emailField = UITextField()
    private let firstNameField = UITextField()
    private let lastNameField = UITextField()
    private let genderField = UITextField()
    private let birthDateField = UITextField()
    private let phoneField = UITextField()
    private let addressField = UITextField()
    private let countryField = UITextField()
    private let cityField = UITextField()
    private let bioField = UITextView()
    
    private let genderPicker = UIPickerView()
    private let genderOptions = ["Не указан", "Мужской", "Женский"]
    
    private let birthDatePicker = UIDatePicker()
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "dd.MM.yyyy"
        return df
    }()
    init(userId: String, email: String) {
            self.userId = userId
            self.userEmail = email
            super.init(nibName: nil, bundle: nil)
            self.title = "Профиль"
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder) // Вызываем super.init
            self.title = "Профиль"
        }
    override func viewDidLoad() {
        super.viewDidLoad()
        edgesForExtendedLayout = []
        setupViews()
        setupPickers()
        fetchProfile()
    }


    private func setupNavigationBar() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save,
                                                            target: self,
                                                            action: #selector(saveProfile))
    }
    
    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let customNavBar = UIView()
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        customNavBar.backgroundColor = .white
        
        view.addSubview(customNavBar)
        
        // Добавляем кнопку в кастомную панель
        let saveButton = UIButton(type: .system)
        saveButton.tintColor = UIColor(red: 171/255, green: 19/255, blue: 68/255, alpha: 1.0)
        saveButton.setTitle("Сохранить", for: .normal)
        saveButton.addTarget(self, action: #selector(saveProfile), for: .touchUpInside)
        
        customNavBar.addSubview(saveButton)
        
        // Устанавливаем ограничения для кастомной панели
        NSLayoutConstraint.activate([
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        // Устанавливаем ограничения для кнопки
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            saveButton.centerYAnchor.constraint(equalTo: customNavBar.centerYAnchor),
            saveButton.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16)
        ])
        
        
        view.addSubview(scrollView)
        NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: customNavBar.bottomAnchor), // Отступ от кастомной панели навигации
                scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
        
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)
        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -16)
        ])
        
        configureTextField(emailField, placeholder: "Почта", isEnabled: false, text: userEmail, leftImage: UIImage(systemName: "envelope"))
        configureTextField(firstNameField, placeholder: "Имя", leftImage: UIImage(systemName: "person.fill"))
        configureTextField(lastNameField, placeholder: "Фамилия", leftImage: UIImage(systemName: "person.fill"))
        configureTextField(genderField, placeholder: "Пол", leftImage: UIImage(systemName: "person"))
        configureTextField(birthDateField, placeholder: "Дата рождения", leftImage: UIImage(systemName: "calendar"))
        configureTextField(phoneField, placeholder: "Телефон", leftImage: UIImage(systemName: "phone"))
        configureTextField(addressField, placeholder: "Адрес", leftImage: UIImage(systemName: "house"))
        configureTextField(countryField, placeholder: "Страна", leftImage: UIImage(systemName: "map"))
        configureTextField(cityField, placeholder: "Город", leftImage: UIImage(systemName: "building.2"))
        configureTextView(bioField, placeholder: "Биография")
        
        phoneField.delegate = self
        birthDateField.delegate = self
        birthDatePicker.maximumDate = Date()


        [emailField, firstNameField, lastNameField, genderField, birthDateField,
         phoneField, addressField, countryField, cityField].forEach { contentStackView.addArrangedSubview($0) }
        contentStackView.addArrangedSubview(bioField)
        
        let logoutButton = UIButton(type: .system)
        logoutButton.setTitle("Выйти из системы", for: .normal)

        logoutButton.backgroundColor = UIColor(red: 171/255, green: 19/255, blue: 68/255, alpha: 1.0)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.layer.cornerRadius = 8
        logoutButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        logoutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        contentStackView.addArrangedSubview(logoutButton)
    }
    
    private func configureTextField(_ textField: UITextField,
                                    placeholder: String,
                                    isEnabled: Bool = true,
                                    text: String? = nil,
                                    leftImage: UIImage? = nil) {
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.isEnabled = isEnabled
        textField.textColor = .darkGray
        textField.text = text
        textField.heightAnchor.constraint(equalToConstant: 44).isActive = true
        if let img = leftImage {
            let imageView = UIImageView(image: img)
            imageView.tintColor = UIColor(red: 171/255, green: 19/255, blue: 68/255, alpha: 1.0)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 44, height: 24))
            container.addSubview(imageView)
            imageView.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
            textField.leftView = container
            textField.leftViewMode = .always
        }
    }
    
    private func configureTextView(_ textView: UITextView, placeholder: String) {
        textView.layer.borderColor = UIColor.gray.cgColor
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 8
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textColor = .black
        textView.heightAnchor.constraint(equalToConstant: 100).isActive = true
    }
    
    private func setupPickers() {
        genderPicker.dataSource = self
        genderPicker.delegate = self
        genderField.inputView = genderPicker
    
        
        birthDatePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            birthDatePicker.preferredDatePickerStyle = .wheels
        }
        birthDatePicker.addTarget(self, action: #selector(birthDateChanged), for: .valueChanged)
        birthDateField.inputView = birthDatePicker
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(donePicker))
        toolbar.setItems([doneButton], animated: false)
        genderField.inputAccessoryView = toolbar
        birthDateField.inputAccessoryView = toolbar
    }
    
    @objc private func birthDateChanged() {
        birthDateField.text = dateFormatter.string(from: birthDatePicker.date)
    }
    
    @objc private func donePicker() {
        view.endEditing(true)
    }
    
    private func fetchProfile() {
        ProfileService.shared.getProfile() { [weak self] profile in
            self?.currentProfile = profile
            DispatchQueue.main.async {
                guard let self = self, let profile = profile else { return }
                self.emailField.text = profile.email
                self.firstNameField.text = profile.firstName
                self.lastNameField.text = profile.lastName
                self.genderField.text = profile.gender
                self.birthDateField.text = profile.birthDate
                self.phoneField.text = profile.phone
                self.addressField.text = profile.address
                self.countryField.text = profile.country
                self.cityField.text = profile.city
                self.bioField.text = profile.bio
            }
        }
    }
    

    @objc private func saveProfile() {
        guard var profile = currentProfile else { return }
        profile.firstName = firstNameField.text ?? ""
        profile.lastName = lastNameField.text ?? ""
        profile.gender = genderField.text ?? "Не указан"
        profile.birthDate = birthDateField.text ?? ""
        profile.phone = phoneField.text ?? ""
        profile.address = addressField.text ?? ""
        profile.country = countryField.text ?? ""
        profile.city = cityField.text ?? ""
        profile.bio = bioField.text ?? ""
        
        ProfileService.shared.updateProfile(profile: profile) { [weak self] error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.showAlert(message: "Ошибка обновления: \(error.localizedDescription)")
                } else {
                    self?.showAlert(message: "Профиль успешно обновлен")
                }
            }
        }
    }
    
    @objc private func logout() {
        AuthenticationService.shared.logoutUser { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mainVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                        let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                        sceneDelegate?.window?.rootViewController = mainVC
                    }
                case .failure(let error):
                    self?.showAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Информация",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UIPickerViewDataSource & Delegate для выбора пола
extension ProfileViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderOptions.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderOptions[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderField.text = genderOptions[row]
    }
}

extension ProfileViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneField {
            let allowedCharacters = "0123456789"
            let maxLength = 12

            if string.rangeOfCharacter(from: CharacterSet(charactersIn: allowedCharacters).inverted) != nil {
                return false
            }
            
            let newLength = (textField.text?.count ?? 0) - range.length + string.count
            return newLength <= maxLength
        }
        if textField == birthDateField {
                   return false // Блокируем ввод с клавиатуры
               }
        return true
    }
}

