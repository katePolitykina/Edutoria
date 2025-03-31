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
        cell.configure(with: lesson)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension LessonsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedLesson = lessons[indexPath.row]

//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let lessonsVC = storyboard.instantiateViewController(withIdentifier: CourseLessonsListViewController.identifier()) as? CourseLessonsListViewController {
//            lessonsVC.courseName = selectedCourse.name
//                        self.navigationController?.pushViewController(lessonsVC, animated: true)
//                    }
    }
}

