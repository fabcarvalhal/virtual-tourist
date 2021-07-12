import Foundation
import CoreData

final class CoreDataManager {
    
    private(set) static var shared = CoreDataManager()
    private(set) static var defaultContainerName = "virtual_tourist"
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private var persistentContainer: NSPersistentContainer!
    
    private init() {}
    
    func configure(with modelName: String = defaultContainerName) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion: ((Error?) -> Void)? = nil) {
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?(error)
        }
    }
}
