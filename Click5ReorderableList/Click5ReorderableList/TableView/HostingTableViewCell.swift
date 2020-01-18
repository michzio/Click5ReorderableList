//
//  _HostingTableViewCell.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import SwiftUI

class HostingTableViewCell: UITableViewCell {
    
    func host<Content: View>(rootView: Content) {
        
        self.contentView.subviews.forEach {  $0.removeFromSuperview() }
        
        let view = UIHostingController(rootView: rootView).view
        view?.backgroundColor = .clear
        
        self.contentView.addSubview(view!)
        
        view!.preservesSuperviewLayoutMargins = true
        view!.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            view!.leadingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leadingAnchor),
            view!.trailingAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.trailingAnchor),
            view!.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            view!.bottomAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.bottomAnchor)
        ])
        
    }
}
