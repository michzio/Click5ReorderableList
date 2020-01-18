//
//  ReorderIndexPath.swift
//  Click5ReorderableList
//
//  Created by Michal Ziobro on 18/01/2020.
//  Copyright © 2020 Click 5 Interactive. All rights reserved.
//

import Foundation
import MobileCoreServices

final class ReorderIndexPath: NSIndexPath {

}

extension ReorderIndexPath : NSItemProviderWriting {
    
    public static var writableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    
    public func loadData(withTypeIdentifier typeIdentifier: String, forItemProviderCompletionHandler completionHandler: @escaping (Data?, Error?) -> Void) -> Progress? {
        
        let progress = Progress(totalUnitCount: 100)
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: self, requiringSecureCoding: false)
            
            progress.completedUnitCount = 100
            
            completionHandler(data, nil)
        } catch {
            completionHandler(nil, error)
        }
        
        return progress
    }
}

extension ReorderIndexPath : NSItemProviderReading {
    
    public static var readableTypeIdentifiersForItemProvider: [String] {
        return [kUTTypeData as String]
    }
    
    public static func object(withItemProviderData data: Data, typeIdentifier: String) throws -> ReorderIndexPath {
        
        do {
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as! ReorderIndexPath
        } catch {
            fatalError(error.localizedDescription)
        }
    }
}
