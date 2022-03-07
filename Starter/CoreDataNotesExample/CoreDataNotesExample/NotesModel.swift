import Foundation
import UIKit

typealias NotesModel = [NotesModelItem]

struct NotesModelItem {
    var noteText: String
    var priorityColor: UIColor

    init(noteText: String = "", priorityColor: UIColor = .clear) {
        self.noteText = noteText
        self.priorityColor = priorityColor
    }
}
