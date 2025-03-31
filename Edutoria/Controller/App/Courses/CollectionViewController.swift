//
//  CollectionViewController.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 24.03.25.
//

import UIKit

class CollectionViewController: UIViewController {
    
    @IBOutlet var collectionView: UICollectionView!
    var categories: [(name: String, imageUrl: String)] = [] // Храним категории
    var favouriteCoursesId: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        collectionView.collectionViewLayout = layout
               
        collectionView.register(MyCollectionViewCell.nib(), forCellWithReuseIdentifier: MyCollectionViewCell.identifier())
        collectionView.delegate = self
        collectionView.dataSource = self
        
        loadCategories()
    }

    func loadCategories() {

        FirestoreService.shared.fetchCategories { [weak self] categories, error in
            guard let self = self else { return }
            if let error = error {
                print("Ошибка загрузки категорий: \(error.localizedDescription)")
                return
            }
            self.categories = categories ?? []
            print("Загружено категорий: \(categories?.count ?? 0)")

                   if let categories = categories {
                       for category in categories {
                           print("Категория: \(category.name), Image URL: \(category.imageUrl)")
                       }
                   }
                   
            print("Категории загружены: \(categories ?? [])")
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionViewController: UICollectionViewDelegate {
 
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedCategory = categories[indexPath.item]
        
        FirestoreService.shared.fetchCourses(for: selectedCategory.name) { [weak self] courses, error in
            guard let self = self else { return }
            
            if let error = error {
                print(" Ошибка загрузки курсов: \(error.localizedDescription)")
                return
            }
            
            FirestoreService.shared.getFavouriteCourses { [weak self] (favouriteCourses, error) in
                guard let self = self else { return }

                if let favouriteCourses = favouriteCourses {
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    // Создаем и настраиваем новый контроллер
                    if let coursesVC = storyboard.instantiateViewController(withIdentifier: "CoursesListViewController") as? CoursesListViewController {
                        coursesVC.courses = courses ?? [] // Передаем курсы категории
                        coursesVC.categoryName = selectedCategory.name
                        self.navigationController?.pushViewController(coursesVC, animated: true)
                    }
                } else {
                    // Обработка ошибки при загрузке избранных курсов
                    print("Error loading favourite courses: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }

    }
   
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//           let selectedCategory = categories[indexPath.item]
//           
//           // Загружаем курсы для выбранной категории
//           FirestoreService.shared.fetchCourses(for: selectedCategory.name) { [weak self] courses, error in
//               guard let self = self else { return }
//               
//               if let error = error {
//                   print("Ошибка загрузки курсов: \(error.localizedDescription)")
//                   return
//               }
//               
//               // Создаем и настраиваем новый контроллер
//               let storyboard = UIStoryboard(name: "Main", bundle: nil)
//               
//               if let coursesVC = storyboard.instantiateViewController(withIdentifier: "CoursesListViewController") as? CoursesListViewController {
//                   coursesVC.courses = courses ?? [] // Передаем курсы категории
//                   coursesVC.categoryName = selectedCategory.name
//                   
//    
//                   
//                   self.navigationController?.pushViewController(coursesVC, animated: true)
//               }
//           }
//   }
    
}




// MARK: - UICollectionViewDataSource
extension CollectionViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyCollectionViewCell.identifier(), for: indexPath) as! MyCollectionViewCell
        let category = categories[indexPath.item]
        cell.configure(with: category)
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow: CGFloat = 2
        let spacing: CGFloat = 10
        let totalSpacing = (itemsPerRow - 1) * spacing + 20 // Отступы слева и справа
        let width = (collectionView.frame.width - totalSpacing) / itemsPerRow
        let height = width * 1.2
        return CGSize(width: width, height: height)
    }
}
