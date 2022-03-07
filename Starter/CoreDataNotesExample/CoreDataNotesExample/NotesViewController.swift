import UIKit

class NotesViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var addNoteButton: UIBarButtonItem!

    var notes = NotesModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView()
    }

    func configureView() {
        // Navigation Bar
        UIHelper().setCustomNavigationTitle(title: "CoreDataNotesExample", navItem: navigationItem)
        UIHelper().setNavigationBar(tintColor: .white, navController: navigationController, navItem: self.navigationItem)
        // TableView
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .jcRed
        self.tableView.separatorStyle = .none
        self.tableView.register(NoteCell.nib, forCellReuseIdentifier: NoteCell.identifier)
    }

    @IBAction func addNoteButtonAction(_ sender: UIBarButtonItem) {
        // Open pop up to create a new note.
        let addNoteVC = AddNoteViewController(nibName: AddNoteViewController.identifier, bundle: nil)
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .custom

        // Closure returns the note and selected priority from the AddNoteViewController, and we insert it at the top of the list.
        addNoteVC.saveNote = { [weak self] noteText, priorityColor in
            guard let self = self else { return }
            self.notes.insert(NotesModelItem(noteText: noteText, priorityColor: priorityColor), at: 0)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }

        present(addNoteVC, animated: true, completion: nil)
    }
}

extension NotesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }

    // Show notes in the list.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.identifier, for: indexPath) as? NoteCell else { fatalError("xib doesn't exist") }
        let currentNote = self.notes[indexPath.row]
        // Note Text
        cell.contentTextLabel.text = currentNote.noteText
        // Priority
        cell.priorityView.backgroundColor = currentNote.priorityColor
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Open the popup to edit the selected note.
        let currentNote = self.notes[indexPath.row]
        let addNoteVC = AddNoteViewController(nibName: AddNoteViewController.identifier, bundle: nil)
        addNoteVC.modalTransitionStyle = .crossDissolve
        addNoteVC.modalPresentationStyle = .custom
        addNoteVC.setNote(text: currentNote.noteText, priorityColor: currentNote.priorityColor)

        // Closure returns the edited note and priority from the AddNoteViewController, and we replace the previous note.
        addNoteVC.saveNote = { [weak self] noteText, priorityColor in
            guard let self = self else { return }
            self.notes[indexPath.row] = NotesModelItem(noteText: noteText, priorityColor: priorityColor)
            DispatchQueue.main.async {
                self.tableView.beginUpdates()
                self.tableView.reloadRows(at: [indexPath], with: .fade)
                self.tableView.endUpdates()
            }
        }
        present(addNoteVC, animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NoteCell else { fatalError("xib doesn't exist") }
        cell.bgView.backgroundColor = .jcRedVeryDark
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? NoteCell else { fatalError("xib doesn't exist") }
        cell.bgView.backgroundColor = .jcRedDark
    }

    // Swipe to delete a note
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, complete in
            // Remove the note from the
            self.notes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            complete(true)
        }
        deleteAction.image = UIImage(systemName: "xmark.circle")
        deleteAction.backgroundColor = .jcRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
}
