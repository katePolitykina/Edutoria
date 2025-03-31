
import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    private let CategoriesCollectionName = "courseCategories"
    private let CoursesCollectionName = "Courses"
    private let LessonsCollectionName = "Lessons"
    
    private init() {}


    /// Получение категорий курсов
    func fetchCategories(completion: @escaping ([(name: String, imageUrl: String)]?, Error?) -> Void) {
        db.collection(CategoriesCollectionName).getDocuments { snapshot, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let documents = snapshot?.documents else {
                completion([], nil)
                return
            }
            
            let categories = documents.compactMap { doc -> (String, String)? in
                let name = doc["name"] as? String ?? "Без названия"
                let imageUrl = doc["imageUrl"] as? String ?? ""
                return (name, imageUrl)
            }
            
            completion(categories, nil)
        }
    }

    // MARK: - Получение ссылок на категорию
    func getCategoryReference(for categoryName: String, completion: @escaping (DocumentReference?) -> Void) {
        db.collection(CategoriesCollectionName)
            .whereField("name", isEqualTo: categoryName)
            .getDocuments { snapshot, error in
                if let error = error {
                    print("Ошибка получения reference для категории \(categoryName): \(error.localizedDescription)")
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    print("Категория \(categoryName) не найдена")
                    completion(nil)
                    return
                }
                
                completion(document.reference)
            }
    }


    
    func fetchCourses(for categoryName: String, completion: @escaping ([Course]?, Error?) -> Void) {
        getCategoryReference(for: categoryName) { [weak self] categoryRef in
            guard let self = self, let categoryRef = categoryRef else {
                print("❌ Ошибка: Категория \(categoryName) не найдена.")
                completion([], nil)
                return
            }
            
            print("🔗 Найдена категория: \(categoryRef.path), загружаем курсы...")
            
            self.db.collection(self.CoursesCollectionName)
                .whereField("courseCategory", isEqualTo: categoryRef) // Фильтруем по DocumentReference
                .getDocuments { snapshot, error in
                    if let error = error {
                        print("❌ Ошибка получения курсов: \(error.localizedDescription)")
                        completion(nil, error)
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        print("⚠️ Нет документов курсов в Firestore")
                        completion([], nil)
                        return
                    }
                    
                    print("✅ Найдено курсов: \(documents.count)")
                    
                    let courses = documents.compactMap { doc -> Course? in
                        let id = doc.documentID
                        let name = doc["name"] as? String ?? "Без названия"
                        let imageUrl = doc["imageUrl"] as? String ?? ""
                        let course = Course(id: id, name: name, imageURL: imageUrl)
                        return course
                    }
                    
                    print("📌 Всего курсов: \(courses.count)")
                    completion(courses, nil)
                }
        }
    }


    
    
    // Получение уроков из подколлекции Lessons курса по его ID
    func fetchLessons(for courseId: String, completion: @escaping ([Lesson]?, Error?) -> Void) {
       // Шаг 1: Найти курс по ID в коллекции Courses
       db.collection(CoursesCollectionName).document(courseId).getDocument { (document, error) in
           if let error = error {
               print("Ошибка при поиске курса: \(error.localizedDescription)")
               completion(nil, error)
               return
           }
           
           guard let document = document, document.exists else {
               print("Курс с ID \(courseId) не найден")
               completion(nil, nil)
               return
           }
           
           // Шаг 2: Получаем ссылку на подколлекцию Lessons
           let courseReference = document.reference
           courseReference.collection("Lessons").getDocuments { (snapshot, error) in
               if let error = error {
                   print("Ошибка при получении уроков: \(error.localizedDescription)")
                   completion(nil, error)
                   return
               }
               
               // Шаг 3: Создаем массив с названиями уроков
               var lessons: [Lesson] = []
               
               snapshot?.documents.forEach { doc in
                   let id = doc.documentID
                   let name = doc["name"] as? String ?? "Без названия"
                   let topics = doc["topics"] as? [String]
                   let orderNumber = doc["order"] as? Int ?? 0
                   let lesson = Lesson(id: id, name: name, topics: topics ?? [], orderNumber: orderNumber)
                   lessons.append(lesson)
               }
               let sortedLessons: [Lesson] = lessons.sorted { (lesson1: Lesson, lesson2: Lesson) in
                   lesson1.orderNumber < lesson2.orderNumber
               }


               print("Найдено уроков: \(lessons.count)")
               completion(sortedLessons, nil)
           }
       }
       }
    
    
    func getFavouriteCourses(completion: @escaping ([Course]?, Error?) -> Void) {
        print("Метод getFavouriteCourses вызван") // Логируем начало метода
        
        guard let userID = AuthenticationService.shared.getCurrentUserID() else {
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(userID)
        
        userRef.getDocument { document, error in
            if let error = error {
                print("Ошибка получения документа: \(error.localizedDescription)")
                completion(nil, error)
                return
            }

            guard let document = document, document.exists else {
                completion([], nil)
                return
            }

            guard let data = document.data(),
                  let favouriteCourseIDs = data["favourite"] as? [String] else {
                completion([], nil)
                return
            }

            // Теперь загружаем курсы по их ID
            var courses: [Course] = []
            let dispatchGroup = DispatchGroup()

            for courseID in favouriteCourseIDs {
                dispatchGroup.enter()
                let courseRef = Firestore.firestore().collection("Courses").document(courseID)
                
                courseRef.getDocument { courseDocument, error in
                    if let error = error {
                        print("Ошибка при получении курса: \(error.localizedDescription)")
                    } else if let courseDocument = courseDocument, courseDocument.exists,
                              let courseData = courseDocument.data() {
                        let id = courseDocument.documentID
                        let name = courseData["name"] as? String ?? "Неизвестный курс"
                        let imageURL = courseData["imageURL"] as? String ?? ""
                        
                        let course = Course(id: id, name: name, imageURL: imageURL)
                        courses.append(course)
                    }
                    dispatchGroup.leave()
                }
            }

            dispatchGroup.notify(queue: .main) {
                completion(courses, nil)
            }
        }
    }

    func addCourseToFavourite(_ course: Course, completion: @escaping (Bool) -> Void) {
        guard let userId = AuthenticationService.shared.getCurrentUserID()  else {
               completion(false)
               return
           }
           let userRef = Firestore.firestore().collection("users").document(userId)
                
            userRef.updateData([
                    "favourite": FieldValue.arrayUnion([course.id])
                ]) { error in
                    if let error = error {
                        print("Ошибка при добавлении курса в избранное: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
       }
       
       // Метод для удаления курса из избранного
    func removeCourseFromFavourite(_ course: Course, completion: @escaping (Bool) -> Void) {
        guard let userId = AuthenticationService.shared.getCurrentUserID()  else {
               completion(false)
               return
           }
            
            let userRef = Firestore.firestore().collection("users").document(userId)
            
            // Обновляем массив favouriteCourses, удаляя ссылку на курс
            userRef.updateData([
                "favourite": FieldValue.arrayRemove([course.id])
            ]) { error in
                if let error = error {
                    print("Ошибка при удалении курса из избранного: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
}
