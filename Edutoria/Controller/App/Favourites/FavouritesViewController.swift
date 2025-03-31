import UIKit

class FavouritesViewController: UINavigationController {
    
    var favouriteCourses: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    override func viewWillAppear(_ animated: Bool) {
       
        
        loadFavouriteCourses()
        super.viewWillAppear(animated)
        
    
    }
    private func loadFavouriteCourses() {
        // Загружаем избранные курсы из Firestore
        FirestoreService.shared.getFavouriteCourses { [weak self] (courses, error) in
            guard let self = self else { return }

            if let courses = courses {
                self.favouriteCourses = courses
                // Обновляем rootViewController с новыми данными
                if let rootVC = self.viewControllers.first as? CoursesListViewController {
                    rootVC.courses = courses
                    Favourite.shared.courses = courses
                    rootVC.tableView.reloadData()  // Перезагружаем таблицу с новыми данными
                }
            } else {
                // Обработка ошибки, например, отображение сообщения об ошибке
                print("Error loading favourite courses: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
}
