//
//  FirestoreService.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 27.03.25.
//
import Foundation
import FirebaseFirestore

class FirestoreService {
    static let shared = FirestoreService()
    private let db = Firestore.firestore()
    
    func fetchCategories(completion: @escaping ([(name: String, imageUrl: String)]?, Error?) -> Void) {
        Firestore.firestore().clearPersistence { _ in
            print("Кэш Firestore очищен")
        }
        db.collection("courseСategories").getDocuments { snapshot, error in // дурацкое имя
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
}

