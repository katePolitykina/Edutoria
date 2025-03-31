import Foundation
import FirebaseFirestore

class ProfileService {
    private let db = Firestore.firestore()
    static let shared = ProfileService()
    
    func getProfileStream(completion: @escaping (UserProfile?) -> Void) -> ListenerRegistration? {
        guard let userId = AuthenticationService.shared.getCurrentUserID() else {
            completion(UserProfile.empty())
            return nil}
        let listener = db.collection("users").document(userId).addSnapshotListener { snapshot, error in
            if let snapshot = snapshot, snapshot.exists, let data = snapshot.data() {
                let profile = UserProfile(id: snapshot.documentID, data: data)
                completion(profile)
            } else {
                completion(UserProfile.empty(userId: userId))
            }
        }
        return listener
    }
     func getProfile(completion: @escaping (UserProfile?) -> Void) {
        guard let userId = AuthenticationService.shared.getCurrentUserID() else {
            return completion(UserProfile.empty())
        }
        let userRef = Firestore.firestore().collection("users").document(userId)
         userRef.getDocument { document, error in
             if let error = error {
                 print("Ошибка получения документа: \(error.localizedDescription)")
                 completion(nil)
                 return
             }
             
             guard let document = document, document.exists else {
                 completion(nil)
                 return
             }
             if let data = document.data() {
                 let profile = UserProfile(id: document.documentID, data: data)
                 completion(profile)
             } else {
                 // Если данных нет, передаем пустой профиль
                 completion(UserProfile.empty(userId: userId))
             }
             
         }
    }
    func updateProfile(profile: UserProfile, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(profile.id).updateData(profile.toFirestore(), completion: completion)
    }
    
    func createInitialProfile(profile: UserProfile, completion: @escaping (Error?) -> Void) {
        let docRef = db.collection("users").document(profile.id)
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(nil)
            } else {
                var data = profile.toFirestore()
                data["emailVerified"] = false
                data["createdAt"] = FieldValue.serverTimestamp()
                docRef.setData(data, completion: completion)
            }
        }
    }
}
