//
//  CourseLessonsListViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 30.03.25.
//

import UIKit

class LessonsListViewController: UIViewController{
   
    @IBOutlet var tableView: UITableView!
    var courseId: String?
    var courseName: String?
    var image = ""
    var lessons: [Lesson] = []
    
    static func identifier() -> String {
        return "LessonsListViewController"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = courseName
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(LessonsListTableViewCell.nib(), forCellReuseIdentifier: LessonsListTableViewCell.identifier())
        tableView.rowHeight = UITableView.automaticDimension
        
        
        guard courseId != nil else { return }
        FirestoreService.shared.fetchLessons(for: courseId!) { [weak self] lessons, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка загрузки категорий: \(error.localizedDescription)")
                return
            }
            self.lessons = lessons ?? []
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        
    }

    
}

// MARK: - UITableViewDataSource
extension LessonsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return lessons.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: LessonsListTableViewCell.identifier(), for: indexPath) as! LessonsListTableViewCell
        let lesson = lessons[indexPath.row]
        cell.configure(with: lesson, image: self.image)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LessonsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedLesson = lessons[indexPath.row]
        
        FirestoreService.shared.getLesson(lessonId: selectedLesson.id, courseId: courseId ?? "") { lessonDetails, error in
            if let error = error {
                print("Ошибка: \(error.localizedDescription)")
            } else if let lessonDetails = lessonDetails {
                
                let lessonVC = DetailsViewController()
                lessonVC.lesson = lessonDetails
                lessonVC.title = selectedLesson.name
                self.navigationController?.pushViewController(lessonVC, animated: true)

                
                
            } else {
                print("Урок не найден")
            }
        }
       
    }
}

