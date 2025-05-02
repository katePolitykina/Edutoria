//
//  LessonDetails.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 31.03.25.
//

//
//  UserProfile.swift
//  Edutoria
//
//  Created by Ekaterina Politykina on 31.03.25.
//

import Foundation

struct LessonDetails {
    let id: String
    let images: [String]
    let description: String
    
    init(id: String, data: [String: Any]) {
        self.id = id
        self.description = data["description"] as? String ?? ""
        self.images = data["images"] as? [String] ?? []
    }
    
    func toFirestore() -> [String: Any] {
        return [
            "description": description,
            "images": images
        ]
    }
    
    static func empty(lessonId: String = "") -> LessonDetails {
        return LessonDetails(id: lessonId, data: [
            "description": "",
            "images": []
        ])
    }
}

