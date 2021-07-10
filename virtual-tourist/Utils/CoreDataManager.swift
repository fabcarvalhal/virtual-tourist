import Foundation
import CoreData

final class CoreDataManager {
    
    private(set) static var shared = CoreDataManager()
    private(set) static var defaultContainerName = "virtual_tourist"
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    var persistentContainer: NSPersistentContainer!
    var backgroundContext: NSManagedObjectContext!
    
    private init() {}
    
    func configure(with modelName: String = defaultContainerName) {
        persistentContainer = NSPersistentContainer(name: modelName)
        backgroundContext = persistentContainer.newBackgroundContext()
    }
    
    private func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        backgroundContext.automaticallyMergesChangesFromParent = true
        
        backgroundContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: ((Error?) -> Void)? = nil) {
        persistentContainer.loadPersistentStores { [weak self] storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self?.configureContexts()
            completion?(error)
        }
    }
}
