import UIKit

class AddNoteViewController: UIViewController {
    @IBOutlet var noteBgView: UIView!
    @IBOutlet var noteLabel: UILabel!
    @IBOutlet var noteTextView: UITextView!
    @IBOutlet var priorityLabel: UILabel!
    @IBOutlet var lowPriorityView: UIView!
    @IBOutlet var mediumPriorityView: UIView!
    @IBOutlet var highPriorityView: UIView!
    @IBOutlet var addNoteButton: UIButton!
    private var keyboardShown: Bool = false
    private var noteViewAlreadyAnimated: Bool = false
    private var noteBgViewOriginY: CGFloat = 0
    private var noteBgViewOriginYWithKeyboard: CGFloat = 0
    private var allowTapBgToClose: Bool? = true
    class var identifier: String { return String(describing: self) }

    var saveNote: ((_ noteText: String, _ priorityColor: UIColor) -> Void)?
    private var savedNote: String?
    private var selectedPriority: UIColor?

    // Pass the data from the list to the popup (this view).
    func setNote(text: String = "", priorityColor: UIColor = .clear) {
        savedNote = text
        selectedPriority = priorityColor
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self) // Keyboard State Notification
    }

    func initView() {
        // View
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.3)

        // Tap Gesture for closing the pop up when you tap outside
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.onBaseTapOnly))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        self.view.addGestureRecognizer(tapRecognizer)

        // Open & Close Keyboard Notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil)

        // Background
        self.noteBgView.backgroundColor = .jcRed
        self.noteBgView.layer.cornerRadius = 12
        self.noteBgView.clipsToBounds = true

        // Note Title
        self.noteLabel.text = "Note"
        self.noteLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        self.noteLabel.textColor = .white

        // Note TextView
        self.noteTextView.text = savedNote
        self.noteTextView.clipsToBounds = true
        self.noteTextView.layer.borderColor = UIColor.white.cgColor
        self.noteTextView.backgroundColor = .jcRedDark
        self.noteTextView.layer.borderWidth = 2.0
        self.noteTextView.layer.cornerRadius = 12
        self.noteTextView.autocorrectionType = .no
        self.noteTextView.font = UIFont.systemFont(ofSize: 14)
        self.noteTextView.tintColor = .white
        self.noteTextView.textColor = .white
        self.noteTextView.contentInset = UIEdgeInsets(top: 0, left: 1, bottom: 2, right: 1)

        // Priority Title
        self.priorityLabel.text = "Priority"
        self.priorityLabel.textColor = .white
        self.priorityLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)

        // Priority Views
        lowPriorityView.backgroundColor = .green
        mediumPriorityView.backgroundColor = .orange
        highPriorityView.backgroundColor = .red
        let priorityViews = [lowPriorityView, mediumPriorityView, highPriorityView]
        for i in 0 ..< priorityViews.count {
            guard let priorityView = priorityViews[i] else { return }
            let tapGes = UITapGestureRecognizer(target: self, action: #selector(selectPriority(_:)))
            tapGes.numberOfTapsRequired = 1
            priorityView.tag = i
            priorityView.addGestureRecognizer(tapGes)

            priorityView.clipsToBounds = true
            priorityView.layer.cornerRadius = 15
            priorityView.layer.borderColor = UIColor.white.cgColor
        }
        setSelectedPriority() // Set the chosen already priority when you edit a note.

        // Add Note Button
        self.addNoteButton.setTitleColor(.white, for: .normal)
        self.addNoteButton.setTitle("Add/Update Note", for: .normal)
        self.addNoteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.addNoteButton.backgroundColor = .jcRedVeryDark
        self.addNoteButton.layer.cornerRadius = 22.5
        self.addNoteButton.addTarget(self, action: #selector(self.addNoteButtonTapped), for: .touchUpInside)
    }

    func setSelectedPriority() {
        guard let selectedPriority = selectedPriority else { return }
        switch selectedPriority {
        case .green:
            priorityLabel.text = "Low priority"
            lowPriorityView.layer.borderWidth = 2
        case .orange:
            priorityLabel.text = "Medium priority"
            mediumPriorityView.layer.borderWidth = 2
        case .red:
            priorityLabel.text = "High priority"
            highPriorityView.layer.borderWidth = 2
        default:
            break
        }
    }

    @objc func selectPriority(_ sender: UITapGestureRecognizer) {
        if sender.view!.tag == 0 { // Low priority
            selectedPriority = lowPriorityView.backgroundColor
            priorityLabel.text = "Low priority"
            lowPriorityView.layer.borderWidth = 2
            mediumPriorityView.layer.borderWidth = 0
            highPriorityView.layer.borderWidth = 0
        } else if sender.view!.tag == 1 { // Medium priority
            selectedPriority = mediumPriorityView.backgroundColor
            priorityLabel.text = "Medium priority"
            lowPriorityView.layer.borderWidth = 0
            mediumPriorityView.layer.borderWidth = 2
            highPriorityView.layer.borderWidth = 0
        } else if sender.view!.tag == 2 { // High priority
            selectedPriority = highPriorityView.backgroundColor
            priorityLabel.text = "High priority"
            lowPriorityView.layer.borderWidth = 0
            mediumPriorityView.layer.borderWidth = 0
            highPriorityView.layer.borderWidth = 2
        }
    }

    @objc func addNoteButtonTapped() {
        self.dismissKeyboard()
        // Check if the note is empty
        if !noteTextView.text.trimmingCharacters(in: .whitespaces).isEmpty, selectedPriority != nil {
            // Save note and close the current view.
            saveNote?(noteTextView.text, selectedPriority!)
            DispatchQueue.main.async {
                self.closeAnim()
            }
        }
    }

    @objc func keyboardWillShow(_ notification: Notification) {
        // Avoid to fire keyboardWillShow when the user taps textview again and again.
        let userInfo = notification.userInfo!
        let beginFrameValue = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)!
        let beginFrame = beginFrameValue.cgRectValue
        let endFrameValue = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)!
        let endFrame = endFrameValue.cgRectValue

        if beginFrame.equalTo(endFrame) {
            return
        }

        // Move the view is hidden behind the keyboard.
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            self.keyboardShown = true
            self.moveViewForKeyboard(frame: keyboardFrame)
        }
    }

    func moveViewForKeyboard(frame: NSValue) {
        let keyboardRectangle = frame.cgRectValue
        let distance = self.noteBgView.frame.maxY - keyboardRectangle.minY
        if distance >= -8 { // Move view only if the view is hidding behind keyboard or is very close.
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                    let bottomSafeAreaPadding = self.view?.window?.safeAreaInsets.bottom
                    let bottomPadding: CGFloat = -45 + (bottomSafeAreaPadding ?? 0.0)
                    self.noteBgView.frame.origin.y -= distance - bottomPadding
                    self.noteBgViewOriginYWithKeyboard = self.noteBgView.frame.origin.y
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        self.keyboardShown = false
    }

    func dismissKeyboard() {
        view.endEditing(true)
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.noteBgView.frame.origin.y = self.noteBgViewOriginY
                self.view.layoutIfNeeded()
            })
        }
    }

    func closeAnim() {
        UIView.animate(withDuration: 1.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.noteBgView.frame = CGRect(x: self.view.frame.width / 2 - self.noteBgView.frame.width / 2, y: self.view.frame.height + self.noteBgView.frame.height, width: self.noteBgView.frame.width, height: self.noteBgView.frame.height)
            self.noteBgView.superview?.layoutIfNeeded()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.dismiss(animated: true, completion: nil)
            }
        })
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !self.noteViewAlreadyAnimated {
            self.noteBgView.frame = CGRect(x: self.view.frame.width / 2 - self.noteBgView.frame.width / 2, y: self.view.frame.height + self.noteBgView.frame.height, width: self.noteBgView.frame.width, height: self.noteBgView.frame.height)
            self.noteBgView.superview?.layoutIfNeeded()

            UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                self.noteBgView.frame = CGRect(x: self.view.frame.width / 2 - self.noteBgView.frame.width / 2, y: self.view.frame.height / 2 - self.noteBgView.frame.height / 2, width: self.noteBgView.frame.width, height: self.noteBgView.frame.height)
                self.noteBgView.superview?.layoutIfNeeded()
            })
            // Save the current origin y for later, when the keyboard is hidden to return the view back to the previous position.
            self.noteBgViewOriginY = self.noteBgView.frame.origin.y
            self.noteViewAlreadyAnimated = true
        }

        // Every time you press a priority color circle, the view goes to the center of the screen, no matter what. The following line keeps the view in the proper position every time(with the keyboard closed or open).
        self.noteBgView.frame.origin.y = self.keyboardShown ? self.noteBgViewOriginYWithKeyboard : self.noteBgViewOriginY
    }
}

extension AddNoteViewController: UIGestureRecognizerDelegate {
    @objc func onBaseTapOnly(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if let allowTapToClose = allowTapBgToClose, allowTapToClose {
                if self.keyboardShown {
                    self.dismissKeyboard()
                } else {
                    DispatchQueue.main.async {
                        self.closeAnim()
                    }
                }
            }
        }
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: self.noteBgView))! {
            // If the keyboard appears, you can hide it even when you press the noteBgView.
            return self.keyboardShown
        }
        return true
    }
}
