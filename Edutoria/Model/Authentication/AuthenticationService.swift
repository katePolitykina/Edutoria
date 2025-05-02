// AuthenticationService.swift

import FirebaseAuth
import FirebaseFirestore

class AuthenticationService {
    
    static let shared = AuthenticationService()
    
    private init() {} // Закрываем инициализацию, чтобы использовать Singleton
    
    // MARK: - Регистрация пользователя
    func registerUser(email: String, password: String, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                // Обработка ошибок Firebase
                let errorMessage: AuthenticationError
                switch AuthErrorCode(rawValue: error.code) {
                case .emailAlreadyInUse:
                    errorMessage = .emailAlreadyInUse
                case .invalidEmail:
                    errorMessage = .invalidEmail
                case .weakPassword:
                    errorMessage = .weakPassword
                default:
                    errorMessage = .genericError("Произошла ошибка при регистрации. Пожалуйста, попробуйте снова.")
                }
                completion(.failure(errorMessage)) // Возвращаем ошибку
                return
            }
            if let user = authResult?.user {
                
                let userId = user.uid
                let data: [String: Any ] = ["email": email]
                Firestore.firestore().collection("users").document(userId).setData(data)
                completion(.success(user))
            }
        }
    }

    // MARK: - Авторизация пользователя
    func loginUser(email: String, password: String, completion: @escaping (Result<User, AuthenticationError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error as NSError? {
                let errorMessage: AuthenticationError
                switch AuthErrorCode(rawValue: error.code) {
                case .invalidCredential, .invalidEmail:
                    errorMessage = .incorrectCredentials
                case .networkError:
                    errorMessage = .genericError("Проблемы с подключением. Пожалуйста, попробуйте снова.")
                case .userDisabled:
                    errorMessage = .genericError("Ваш аккаунт был отключен.")
                case .tooManyRequests:
                    errorMessage = .genericError("Слишком много попыток. Попробуйте позже.")
                default:
                    errorMessage = .genericError("Произошла ошибка при авторизации. Пожалуйста, попробуйте снова.")
                }
                completion(.failure(errorMessage)) // Возвращаем ошибку
                return
            }
            if let user = authResult?.user {
                completion(.success(user))
            }
        }
    }

    // MARK: - Выход из системы
    func logoutUser(completion: @escaping (Result<Void, Error>) -> Void) {
        do {
            try Auth.auth().signOut()
            completion(.success(()))
        } catch {
            completion(.failure(error))
        }
    }

    // MARK: - Проверка авторизации пользователя
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    // Получить UID текущего пользователя
    func getCurrentUserID() -> String? {
        return Auth.auth().currentUser?.uid
    }
    func deleteUser(password: String, completion: @escaping (Result<Void, AuthenticationError>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(.genericError("Пользователь не найден.")))
            return
        }
        guard let email = currentUser.email else {
            completion(.failure(.genericError("Email пользователя не найден.")))
            return
        }
        // Создаем учетные данные с email и паролем для повторной аутентификации
        let credential = EmailAuthProvider.credential(withEmail: currentUser.email!, password: password)
        print(currentUser.email!)
        // Повторная аутентификация пользователя для проверки подлинности перед удалением

        currentUser.reauthenticate(with: credential) { (authResult, error) in
            if let error = error {
                // Обработка ошибок
                let errorMessage: AuthenticationError
                if let authError = error as NSError? {
                    switch AuthErrorCode(rawValue: authError.code) {
                    case .expiredActionCode, .sessionExpired, .userTokenExpired:
                        errorMessage = .genericError("Срок действия токенов истек. Пожалуйста, авторизуйтесь заново.")
                    default:
                        errorMessage = .genericError("Ошибка при повторной аутентификации: \(error.localizedDescription)")
                    }
                } else {
                    errorMessage = .genericError("Не удалось выполнить повторную аутентификацию.")
                }
                completion(.failure(errorMessage))
                return
            }
            // Удаление пользователя из Firebase Auth
            currentUser.delete { error in
                if let error = error {
                    let errorMessage: AuthenticationError
                    errorMessage = .genericError("Не удалось удалить аккаунт. Попробуйте снова.")
                    completion(.failure(errorMessage))
                    return
                }
                
                // Удаление данных пользователя из Firestore
                Firestore.firestore().collection("users").document(currentUser.uid).delete { error in
                    if let error = error {
                        completion(.failure(.genericError("Ошибка при удалении данных пользователя из Firestore.")))
                        return
                    }
                    completion(.success(())) // Успешное удаление аккаунта
                }
            }
        }}
}
