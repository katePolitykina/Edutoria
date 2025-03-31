//
//  Favourite.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 31.03.25.
//
class Favourite {
    static let shared = Favourite()
    var courses: [Course] = []
    
    private init() {
        FirestoreService.shared.getFavouriteCourses { [weak self] (courses, error) in
            guard let self = self else { return }

            if let courses = courses {
                self.courses = courses
               
            } else {
                // Обработка ошибки, например, отображение сообщения об ошибке
                print("Error loading favourite courses: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    } 
}
