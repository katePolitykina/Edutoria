//
//  LessonServise.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 31.03.25.
//
import Foundation
import FirebaseFirestore
class LessonService {
    
    static let shared = LessonService()
    private let db = Firestore.firestore()
    private let CoursesCollectionName = "Courses"
    private let LessonsCollectionName = "Lessons"
    
    private init() {}
    
    func addLessonsToCourse(courseId: String) {
        let db = Firestore.firestore()
        
        // Получаем ссылку на документ курса
        let courseRef = db.collection("Courses").document(courseId)
        
        for i in 1...30 {
            let lessonData: [String: Any] = [
                "name": "Lesson \(i)",
                "description": "This is the description for Lesson \(i).",
                "order": i,
                "topics": ["Topic 1", "Topic 2", "Topic 3"],
                "images": ["https://i.pinimg.com/736x/99/32/1f/99321f1601c934d5ff28667033eeea78.jpg",
                           "https://i.pinimg.com/736x/e3/fe/56/e3fe567628c8b8678a6f9f95d52d1afc.jpg",
                           "https://i.pinimg.com/736x/7a/11/f5/7a11f53f486bcbab4df39cf176e1ea72.jpg",
                           "https://i.pinimg.com/736x/1f/fa/c9/1ffac9ec9386aac620f84e440fbd0cf5.jpg",
                           "https://i.pinimg.com/736x/66/f3/19/66f31941137233927e061781344179cc.jpg"
                          ]
            ]
            
            courseRef.collection("Lessons").addDocument(data: lessonData) { error in
                if let error = error {
                    print("Ошибка при добавлении урока \(i): \(error.localizedDescription)")
                } else {
                    print("Урок \(i) успешно добавлен в курс \(courseId).")
                }
            }
        }
    }
}
