//
//  StorageManager.swift
//  Notes (Vezdekod)
//
//  Created by Alex Yatsenko on 24.04.2021.
//

import CoreData

final class StorageManager {
  
  static var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "NoteDonationDataModel")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
    
  func fetchNotes(completion: (_ result: Result<[Note], Error>) -> Void) {
    do {
      let request: NSFetchRequest<Note> = Note.fetchRequest()
      let notes = try Self.persistentContainer.viewContext.fetch(request)
      completion(.success(notes))
    } catch let error {
      completion(.failure(error))
    }
  }
  
  func saveNote(title: String,
                image: Data?,
                category: String,
                text: String?,
                completion: (Note?) -> Void) {
    let note = Note(context: Self.persistentContainer.viewContext)
    note.title = title
    note.image = image
    note.category = category
    note.creation = Date()
    try? Self.persistentContainer.viewContext.save()
    completion(note)
  }
    
  func delete(note: Note) {
    Self.persistentContainer.viewContext.delete(note)
    try? Self.persistentContainer.viewContext.save()
  }
  
  func edit(note: Note, completion: (_ result: Result<Void, Error>) -> Void) {
    do {
      try Self.persistentContainer.viewContext.save()
      completion(.success(()))
    } catch let error {
      completion(.failure(error))
    }
  }
}

