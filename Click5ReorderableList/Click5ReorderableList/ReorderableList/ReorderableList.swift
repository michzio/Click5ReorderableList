//
//  ReorderableList.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import SwiftUI

struct ReorderableList: UIViewControllerRepresentable {
    
    // MARK: - State
    @State private(set) var model = Model<AnyView>(items: [])
    
    // MARK: - Properties
    private let items: [AnyView]
    
    // MARK: - Actions
    let onReorder : (Int, Int) -> Void
    let onDelete : ((Int) -> Bool)?
    
    
    // MARK: - Init
    public init<Data, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _, _ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Data, Data.Element.ID, RowContent>) where Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {

        let content = content()
        
        var items = [AnyView]()
        
        content.data.forEach { element in
            let item = content.content(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    
    public init<Data, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Data, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Data : RandomAccessCollection, RowContent : View, Data.Element : Identifiable {
        
        self.init(onReorder: onReorder, onDelete: onDelete) {
            ForEach(data) { element in HStack { rowContent(element) } }
        }
    }
    
    
    public init<Data, ID, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Data, ID, RowContent>) where Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        
        let content = content()
        
        var items = [AnyView]()
        
        content.data.forEach { element in
            let item = content.content(element)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
        
    }
    
    public init<Data, ID, RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Data, id: KeyPath<Data.Element, ID>, @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent) where Data : RandomAccessCollection, ID : Hashable, RowContent : View {
        
        self.init(onReorder: onReorder, onDelete: onDelete) {
            ForEach(data, id: id) { element in HStack { rowContent(element) } }
        }
    }
    
    public init<RowContent>(onReorder: @escaping (Int, Int) -> Void = { _,_ in }, onDelete: ((Int) -> Bool)? = nil, _ content: @escaping () -> ForEach<Range<Int>, Int, RowContent>) where RowContent : View {
        
        let content = content()
        
        var items = [AnyView]()
        
        content.data.forEach { i in
            let item = content.content(i)
            items.append(AnyView(item))
        }
        
        self.items = items
        
        self.onReorder = onReorder
        self.onDelete = onDelete
    }
    
    public init<RowContent>(onReorder: @escaping (Int, Int) -> Void = {_,_ in }, onDelete: ((Int) -> Bool)? = nil, _ data: Range<Int>, @ViewBuilder rowContent: @escaping (Int) -> RowContent) where RowContent : View {
        
        self.init(onReorder: onReorder, onDelete: onDelete) {
            ForEach(data) { i in
                HStack { rowContent(i) }
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UITableViewController {
        
        let tableView = UITableViewController()
       
        tableView.tableView.delegate = context.coordinator
        tableView.tableView.dataSource = context.coordinator
        tableView.tableView.dragInteractionEnabled = true
        tableView.tableView.dragDelegate = context.coordinator
        tableView.tableView.dropDelegate = context.coordinator
        
        tableView.tableView.register(HostingTableViewControllerCell<AnyView>.self, forCellReuseIdentifier: "HostingCell")
        
        context.coordinator.controller = tableView
        
        return tableView
    }
    
    func updateUIViewController(_ uiViewController: UITableViewController, context: Context) {
        DispatchQueue.main.async {
            self.model.replaceItems(self.items)
            uiViewController.tableView.reloadData()
        }
    }
    
    class Coordinator: NSObject, UITableViewDelegate, UITableViewDataSource, UITableViewDragDelegate, UITableViewDropDelegate {
    
        // MARK: - Properties
        let parent: ReorderableList
        weak var controller : UITableViewController?
        
        // MARK: - Init
        init(_ parent: ReorderableList) {
            self.parent = parent
        }
        
        // MARK: - Data Source
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            parent.model.items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell") as! HostingTableViewControllerCell<AnyView>
            
            let rootView = parent.model.items[indexPath.row]
            cell.host(rootView, parent: controller!)
            
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

struct ReorderableList_Previews: PreviewProvider {
    static var previews: some View {
        //ReorderableList()
        EmptyView()
    }
}
