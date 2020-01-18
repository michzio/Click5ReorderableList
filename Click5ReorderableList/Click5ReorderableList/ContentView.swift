//
//  ContentView.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var items: [String] = Array(0...1_000).map { "Item \($0)" }
    
    var body: some View {
        
        NavigationView {
            
            ReorderableList2(onReorder: reorder, onDelete: delete) {
                 ForEach(self.items, id: \.self) { item in
                    Text("\(item)")
                }
            }
            .navigationBarTitle("Reorderable List", displayMode: .inline)
            .navigationBarItems(trailing: Button(action: add, label: {
                Image(systemName: "plus")
            }))
        }
    }
    
    func reorder(from source: Int, to destination: Int) {
        items.move(fromOffsets: IndexSet([source]), toOffset: destination)
    }
    
    func delete(_ idx: Int) -> Bool {
        items.remove(at: idx)
        return true
    }
    
    func add() {
        items.append("Item \(items.count)")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
