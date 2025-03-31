import UIKit
import SDWebImage

class CoursesListViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var categoryName: String?
    var courses: [Course] = []
    var favouriteCourses: [Course] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = categoryName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CoursesListTableViewCell.nib(), forCellReuseIdentifier: CoursesListTableViewCell.identifier())
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    deinit {
        print("CoursesListViewController удален из памяти")
    }

    private func loadFavouriteCourses() {
        // Загружаем избранные курсы из Firestore
        FirestoreService.shared.getFavouriteCourses { [weak self] (courses, error) in
            guard let self = self else { return }

            if let courses = courses {
                self.favouriteCourses = courses
            } else {
                // Обработка ошибки, например, отображение сообщения об ошибке
                print("Error loading favourite courses: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Загружаем избранные курсы и обновляем таблицу
        loadFavouriteCourses()
        self.tableView.reloadData()
    }
    
}

// MARK: - UITableViewDataSource
extension CoursesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return courses.count
       }
    
    func isCourseFavorite(course: Course, favoriteCourses: [Course]) -> Bool {
        return favoriteCourses.contains(where: { $0.id == course.id })
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoursesListTableViewCell.identifier(), for: indexPath) as! CoursesListTableViewCell
        let course = courses[indexPath.row]
        
        cell.configure(with: course, isFavourite: isCourseFavorite(course: course, favoriteCourses: favouriteCourses))
        
        cell.onFavouriteTapped = { [weak self] in
            guard let self = self else { return }
            
            if let index = self.courses.firstIndex(where: { $0.id == course.id }) {
                let isCurrentlyFavourite = self.isCourseFavorite(course: course, favoriteCourses: self.favouriteCourses)
                
                if isCurrentlyFavourite {
                    // Удаление из избранного
                    FirestoreService.shared.removeCourseFromFavourite(course) { success in
                        if success {
                            self.favouriteCourses.removeAll { $0.id == course.id }
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        } else {
                            print("Не удалось удалить курс из избранного")
                        }
                    }
                } else {
                    // Добавление в избранное
                    FirestoreService.shared.addCourseToFavourite(course) { success in
                        if success {
                            self.favouriteCourses.append(course)
                            self.tableView.reloadRows(at: [indexPath], with: .automatic)
                        } else {
                            print("Не удалось добавить курс в избранное")
                        }
                    }
                }
                
            }
        }
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CoursesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCourse = courses[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let lessonsVC = storyboard.instantiateViewController(withIdentifier: LessonsListViewController.identifier()) as? LessonsListViewController {
            lessonsVC.courseName = selectedCourse.name
            lessonsVC.courseId = selectedCourse.id
                        self.navigationController?.pushViewController(lessonsVC, animated: true)
                    }
    }
}

