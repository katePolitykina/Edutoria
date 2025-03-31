//
//  CourseLessonsListViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 30.03.25.
//

import UIKit

class CourseLessonsListViewController: UIViewController {
   
    @IBOutlet var tableView: UITableView!
    
    var courseName: String?
    var categoryName: String?
    var courses: [(name: String, imageUrl: String)] = []
    static func identifier() -> String {
        return "CourseLessonsListViewController"
    }
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

    
}

// MARK: - UITableViewDataSource
extension CoursesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return courses.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoursesListTableViewCell.identifier(), for: indexPath) as! CoursesListTableViewCell
        let course = courses[indexPath.row]
        cell.configure(with: course)
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CoursesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedCourse = courses[indexPath.row]

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let lessonsVC = storyboard.instantiateViewController(withIdentifier: CourseLessonsListViewController.identifier()) as? CourseLessonsListViewController {
            lessonsVC.courseName = selectedCourse.name
                        self.navigationController?.pushViewController(lessonsVC, animated: true)
                    }
    }
}

