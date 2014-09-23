import UIKit
import CoreData

class SwiftCoreDataHelper: NSObject {
   
    class func directoryForDatabaseFilename()->NSString{
        return NSHomeDirectory().stringByAppendingString("/Library/Private Documents/")
    }

    class func databaseFilename()->NSString{
        return "database.sqlite";
    }
    
    class func managedObjectContext()->NSManagedObjectContext{

        var error:NSError? = nil
        
        NSFileManager.defaultManager().createDirectoryAtPath(SwiftCoreDataHelper.directoryForDatabaseFilename(), withIntermediateDirectories: true, attributes: nil, error: &error)

        let path:NSString = "\(SwiftCoreDataHelper.directoryForDatabaseFilename()) + \(SwiftCoreDataHelper.databaseFilename())"
        
        let url:NSURL = NSURL(fileURLWithPath: path)
        
        let managedModel:NSManagedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        
        var storeCoordinator:NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedModel)
        
        if !(storeCoordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error:&error ) != nil){
            if (error != nil){
                println(error!.localizedDescription)
                abort()
            }
        }
        
        var managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        return managedObjectContext
    }
    
    class func insertManagedObject(className:String, managedObjectConect:NSManagedObjectContext)->AnyObject{
        let managedObject:NSManagedObject = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectConect) as NSManagedObject

        return managedObject
    }
    
    class func saveManagedObjectContext(managedObjectContext:NSManagedObjectContext)->Bool{
        if managedObjectContext.save(nil){
            return true
        } else {
            return false
        }
    }
    
    class func updateManagedObject(className:String, propertiesToUpdate:NSDictionary, managedObjectConnect:NSManagedObjectContext)->AnyObject{
        var batchRequest = NSBatchUpdateRequest(entityName: className)
        batchRequest.propertiesToUpdate = propertiesToUpdate
        batchRequest.resultType = .UpdatedObjectsCountResultType
        var error : NSError?
        var results = managedObjectConnect.executeRequest(batchRequest,
            error: &error) as NSBatchUpdateResult
        return results
    }

    class func fetchEntities(className:String, withPredicate predicate:NSPredicate?, withSorter input_sorter:NSSortDescriptor?, managedObjectContext:NSManagedObjectContext)->NSArray{
        var error: NSError? = nil
        var fetchRequest: NSFetchRequest = NSFetchRequest(entityName: className)
        
        if(predicate != nil) {
            fetchRequest.predicate = predicate!
        }
        
        if(input_sorter != nil){
            var sorter: NSSortDescriptor = input_sorter!
            fetchRequest.sortDescriptors = [sorter]
        }
        
        fetchRequest.returnsObjectsAsFaults = false
        var results:NSArray = managedObjectContext.executeFetchRequest(fetchRequest, error:&error)!
        
        return results
    }
}
