import CoreData

final class FetchResultsManager<T> where T: NSManagedObject {
    
    private(set) var dataSource: NSFetchedResultsController<T>?
    
    
    func configure(with context: NSManagedObjectContext,
                   delegate: NSFetchedResultsControllerDelegate,
                   request: NSFetchRequest<T>) {
        let controller = NSFetchedResultsController(fetchRequest: request,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: nil,
                                                    cacheName: nil)
        controller.delegate = delegate
        dataSource = controller
    }
    
    func performFetch() {
        try? dataSource?.performFetch()
    }
}
