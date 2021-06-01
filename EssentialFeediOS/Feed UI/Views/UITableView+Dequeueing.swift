//
//  UITableView+Dequeueing.swift
//  EssentialFeediOS
//
//  Created by Alexander on 1/6/21.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
