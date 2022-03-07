import UIKit

class NoteCell: UITableViewCell {
    @IBOutlet var bgView: UIView!
    @IBOutlet var contentTextLabel: UILabel!
    @IBOutlet var priorityView: UIView!

    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    func configureView() {
        // View
        self.backgroundColor = .clear
        self.selectionStyle = .none
        // Background View
        self.bgView.backgroundColor = .jcRedDark
        self.bgView.layer.cornerRadius = 8
        // Content Text
        contentTextLabel.textColor = .white
        // Priority View
        priorityView.layer.cornerRadius = 4
    }
}
