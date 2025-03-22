//
//  AuthenticationError.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 22.03.25.
//

// AuthenticationError.swift

import Foundation

enum AuthenticationError: Error {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case incorrectCredentials
    case genericError(String) // Для произвольных ошибок, например, "Произошла ошибка при регистрации."

    var localizedDescription: String {
        switch self {
        case .emailAlreadyInUse:
            return "Этот адрес электронной почты уже используется."
        case .invalidEmail:
            return "Неверный формат адреса электронной почты."
        case .weakPassword:
            return "Пароль слишком слабый. Используйте более сложный пароль."
        case .incorrectCredentials:
                    return "Неверный пользователь или пароль."
        case .genericError(let message):
            return message
        }
    }
}
