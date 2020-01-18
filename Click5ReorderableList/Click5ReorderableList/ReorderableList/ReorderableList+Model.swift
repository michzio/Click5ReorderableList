//
//  ReorderableList+Model.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import SwiftUI

extension ReorderableList {
    
    struct Model<T> {
        
        private(set) var items : [T]
        
        init(items: [T]) {
            self.items = items
        }
        
        mutating func addItem(_ item: T, at index: Int) {
            items.insert(item, at: index)
        }
        
        mutating func removeItem(at index: Int) {
            items.remove(at: index)
        }
        
        mutating func moveItem(at source: Int, to destination: Int) {
            guard source != destination else { return }
            
            let item = items[source]
            items.remove(at: source)
            items.insert(item, at: destination)
        }
        
        mutating func replaceItems(_ items: [T]) {
            self.items = items
        }
        
        func canHandle(_ session: UIDropSession) -> Bool {
            
            return session.canLoadObjects(ofClass: ReorderIndexPath.self)
        }
        
        func dragItems(for indexPath: IndexPath) -> [UIDragItem] {
            
            //let item = items[indexPath.row]
            //let data = item.data(using: .utf8)
            
            let itemProvider = NSItemProvider()
            itemProvider.registerObject(ReorderIndexPath(row: indexPath.row, section: indexPath.section), visibility: .all)
        
            return [
                UIDragItem(itemProvider: itemProvider)
            ]
            
        }
    }
}
