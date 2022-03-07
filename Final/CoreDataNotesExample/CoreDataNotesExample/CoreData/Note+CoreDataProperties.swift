import CoreData
import Foundation
import UIKit

public extension Note {
    @nonobjc class func fetchRequest() -> NSFetchRequest<Note> {
        return NSFetchRequest<Note>(entityName: "Note")
    }

    @NSManaged var dateAdded: Date?
    @NSManaged var noteText: String?
    @NSManaged var priorityColor: UIColor?
}

extension Note: Identifiable {}
