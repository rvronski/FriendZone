//
//  CoreDataManager.swift
//  FriendZone
//
//  Created by ROMAN VRONSKY on 14.05.2023.
//

import CoreData

class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    init() {}
    
    var likes: [Like] = []
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FriendZone")
        container.loadPersistentStores(completionHandler: {
            (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func searchLike(searchName: String?=nil) -> [Like] {
        let request = Like.fetchRequest()
        if let searchName, searchName != "" {
            request.predicate = NSPredicate(format: "authorText contains[c] %@", searchName)
        }
        
        return (try? persistentContainer.viewContext.fetch(request)) ?? []
       
    }
    func reloadLikes(searchName: String?=nil) {
        let request = Like.fetchRequest()
        self.likes = (try? persistentContainer.viewContext.fetch(request)) ?? []
       
    }
    
    func createLike(authorText: String, descriptionText: String, postImage: Data, tag: String, completion: @escaping (() -> Void) ) {
        persistentContainer.performBackgroundTask { contextBackground in
            let like = Like(context: contextBackground)
            like.authorText = authorText
            like.postImage = postImage
            like.descriptionText = descriptionText
            like.tag = tag
            
            do {
                try contextBackground.save()
                self.reloadLikes()
            } catch {
                print(error)
            }
            completion()
        }
       
    }
    
    func deleteLike(like: Like) {
        persistentContainer.viewContext.delete(like)
        saveContext()
        reloadLikes()
    }
    
//    func save() {
//        UserDefaults.standard.set(true, forKey: "isLike")
//    }
}
