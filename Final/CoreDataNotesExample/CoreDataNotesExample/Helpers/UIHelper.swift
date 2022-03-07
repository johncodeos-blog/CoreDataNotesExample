import Foundation
import UIKit

class UIHelper {

    func setNavigationBar(tintColor: UIColor, navController: UINavigationController?, navItem: UINavigationItem) {
        navController?.navigationBar.isTranslucent = false
        navController?.navigationBar.tintColor = tintColor
        navController?.navigationBar.barTintColor = .jcRed
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .jcRed
            navController?.navigationBar.standardAppearance = appearance
            navController?.navigationBar.scrollEdgeAppearance = appearance
        }
        navController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: tintColor]
        navController?.navigationBar.backItem?.title = ""
        navItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil) // Remove "Back" from Navigation Bar
    }

    func setCustomNavigationTitle(title: String, navItem: UINavigationItem) {
        let titlelabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
        titlelabel.text = title
        titlelabel.textColor = .white
        titlelabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titlelabel.backgroundColor = UIColor.clear
        titlelabel.textAlignment = .center
        navItem.titleView = titlelabel
    }
}
