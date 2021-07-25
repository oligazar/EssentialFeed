//
//  ErrorView.swift
//  EssentialFeediOS
//
//  Created by Alexander on 30/6/21.
//

import UIKit

public class ErrorView: UIView {
    @IBOutlet private(set) public var button: UIButton!
    
    private var isVisible: Bool {
        return alpha > 0
    }
    
    public var message: String? {
        get { return isVisible ? button.title(for: .normal) : nil }
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        button.alpha = 0
        button.setTitle(nil, for: .normal)
    }
    
    @IBAction func hideMessage() {
        UIView.animate(
            withDuration: 0.25,
            animations: { self.alpha = 0 },
            completion: { completed in
                if completed {
                    self.button.setTitle(nil, for: .normal)
                }
            })
    }
    
    func show(message: String) {
        button?.setTitle(message, for: .normal)
        
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1
        }
    }
}
