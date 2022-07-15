//
//  Item+CoreDataProperties.swift
//  InventoryApp-okubo
//
//  Created by 大久保徹郎 on 2022/07/15.
//
//

import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var deadLine: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var image: Data?
    @NSManaged public var isHurry: Bool
    @NSManaged public var name: String?
    @NSManaged public var notificationDate: Date?
    @NSManaged public var numberOfItems: Int16
    @NSManaged public var registrationDate: Date?
    @NSManaged public var status: String?
    @NSManaged public var folder: Folder?

}

extension Item: Identifiable {

}
