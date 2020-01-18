//
//  ReorderableList2.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import SwiftUI

extension ReorderableList2 {
    
    struct Model<T> {
        
        private(set) var items: [T]
        
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
        
        // Drag & Drop
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

struct ReorderableList2: UIViewRepresentable {
    
    // MARK: - State
    @State private(set) var model = Model<AnyView>(items: [])
    
    // MARK: - Properties
    private let items: [AnyView]
    
    // MARK: - Actions
    let onReorder : (Int, Int) -> Void
    let onDelete : ((Int) -> Bool)?
    
    // MARK: - Init
    public init<Data, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _, _ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Data, Data.Element.ID, RowContent>) where Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        
        var items = [AnyView]()
        
        let content = content()
        
        content.data.forEach { element in
            let item = content.content(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
            
    }
    
    public init<Data, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        
        var items = [AnyView]()
        
        data.forEach { element in
            let item = rowContent(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
     public init<Data, ID, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Data, ID, RowContent>) where Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        
        var items = [AnyView]()
        
        let content = content()
        
        content.data.forEach { element in
            let item = content.content(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    public init<Data, ID, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        
        var items = [AnyView]()
        
        data.forEach { element in
            let item = rowContent(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    public init<RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Range<Int>, Int, RowContent>) where RowContent : View {
        
        var items = [AnyView]()
        
        let content = content()
        
        content.data.forEach { element in
            let item = content.content(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    public init<RowContent>(onReorder: @escaping (Int, Int) -> Void = {_,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Range<Int>, @ViewBuilder rowContent: @escaping (Int) -> RowContent) where RowContent : View {
        
        var items = [AnyView]()
        
        data.forEach { element in
            let item = rowContent(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITableView {
        
        let tableView = UITableView()
        
        tableView.delegate = context.coordinator
        tableView.dataSource = context.coordinator
        tableView.dragInteractionEnabled = true
        tableView.dragDelegate = context.coordinator
        tableView.dropDelegate = context.coordinator
        
        tableView.register(HostingTableViewCell.self, forCellReuseIdentifier: "HostingCell")
        
        return tableView
    }
    
    func updateUIView(_ uiView: UITableView, context: Context) {
        DispatchQueue.main.async {
            self.model.replaceItems(self.items)
            uiView.reloadData()
        }
        
    }
    
    class Coordinator : NSObject, UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
        
        // MARK: - Properties
        private let parent: ReorderableList2
        
        // MARK: - Init
        init(_ parent: ReorderableList2) {
            self.parent = parent
        }
        
        // MARK: - Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.model.items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell") as! HostingTableViewCell
            
            let rootView = parent.model.items[indexPath.row]
            cell.host(rootView: rootView)
            
            return cell
        }
        
        // MARK: - Delegate
        func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return parent.onDelete != nil ? .delete : .none
        }
        
        func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
            return false
        }
        
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            
            if editingStyle == .delete {
                if parent.onDelete?(indexPath.row) ?? false {
                    tableView.beginUpdates()
                    parent.model.removeItem(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .fade)
                    tableView.endUpdates()
                }
            } else if editingStyle == .insert {
                
            }
        }
        
        /*
        func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            let object = parent.model.items[sourceIndexPath.row]
            parent.model.items.remove(at: sourceIndexPath.row)
            parent.model.items.insert(object, at: destinationIndexPath.row)
        }
        */
        
        // MARK: - Drag Delegate
        func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
         
            return parent.model.dragItems(for: indexPath)
        }
        
        // MARK: - Drop Delegate
        func tableView(_ tableView: UITableView, canHandle session: UIDropSession) -> Bool {
            return parent.model.canHandle(session)
        }
        
        func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
            
            if tableView.hasActiveDrag {
                if session.items.count > 1 {
                    return UITableViewDropProposal(operation: .cancel)
                } else {
                    return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
                }
            } else {
                return UITableViewDropProposal(operation: .copy, intent: .insertAtDestinationIndexPath)
            }
        }
        
        func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
            
            let destinationIndexPath: IndexPath
            
            if let indexPath = coordinator.destinationIndexPath {
                destinationIndexPath = indexPath
            } else {
                // Get last index path of table view.
                let section = tableView.numberOfSections - 1
                let row = tableView.numberOfRows(inSection: section)
                destinationIndexPath = IndexPath(row: row, section: section)
            }
            
            coordinator.session.loadObjects(ofClass: ReorderIndexPath.self) { items in
                
                // Consume drag items.
                let indexPaths = items as! [IndexPath]
            
                for (index, sourceIndexPath) in indexPaths.enumerated() {
                    
                    let destinationIndexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                    self.parent.model.moveItem(at: sourceIndexPath.row, to: destinationIndexPath.row)
                    
                    tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
                    
                    self.parent.onReorder(sourceIndexPath.row, destinationIndexPath.row)
                }
            }
        }
        
    }
}
