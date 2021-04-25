//
//  Note+CoreDataProperties.swift
//  Notes (Vezdekod)
//
//  Created by Alex Yatsenko on 24.04.2021.
//
//

import CoreData

extension Note {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<Note> {
    return NSFetchRequest<Note>(entityName: "Note")
  }
  
  @NSManaged public var category: String?
  @NSManaged public var title: String?
  @NSManaged public var creation: Date?
  @NSManaged public var image: Data?
  @NSManaged public var text: String?
  
}

extension Note : Identifiable {
  
}
