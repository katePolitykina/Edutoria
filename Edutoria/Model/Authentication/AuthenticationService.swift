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
}
