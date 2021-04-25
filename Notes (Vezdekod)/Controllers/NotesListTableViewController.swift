//
//  NotesListTableViewController.swift
//  Notes (Vezdekod)
//
//  Created by Alex Yatsenko on 24.04.2021.
//

import UIKit

final class NotesListTableViewController: UITableViewController, UISearchResultsUpdating {
  
  private let searchController = UISearchController(searchResultsController: nil)
  private var searchBarIsEmpty: Bool {
      guard let text = searchController.searchBar.text else { return true }
      return text.isEmpty
  }
  private var isFiltering: Bool {
      return !searchBarIsEmpty
  }
  private let storageManager = StorageManager()
  private var filteredNotes = [Note]()
  private var notes = [Note]()
  private let errorLabel: UILabel = {
    let label = UILabel()
    label.textAlignment = .center
    label.font = .systemFont(ofSize: 24)
    label.numberOfLines = 0
    label.text = "Create note at first"
    return label
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupNavigationItem()
    tableView.backgroundView = errorLabel
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    getData()
  }
  
  private func getData() {
    storageManager.fetchNotes { [weak self] result in
      switch result {
      case .success(let notes):
        self?.notes = notes
        if !notes.isEmpty {
          tableView.reloadData()
          errorLabel.isHidden = true
        }
      case .failure(let error):
        print("Failed to fetch notes", error.localizedDescription)
      }
    }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetail",
       let detailVC = segue.destination as? NoteTableViewController,
       let indexPath = tableView.indexPathForSelectedRow {
      detailVC.state = .detail
      detailVC.note = isFiltering ? filteredNotes[indexPath.row] : notes[indexPath.row]
      tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return isFiltering ? filteredNotes.count : notes.count
  }
  
  override func tableView(_ tableView: UITableView,
                          cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "note", for: indexPath)
    let note = isFiltering ? filteredNotes[indexPath.row] : notes[indexPath.row]
    (cell as? NoteCell)?.updateUI(with: note)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
      let note = isFiltering ? filteredNotes[indexPath.row] : notes[indexPath.row]
      storageManager.delete(note: note)
      notes.remove(at: indexPath.row)
      if notes.isEmpty {
        errorLabel.isHidden = false
      }
      tableView.deleteRows(at: [indexPath], with: .automatic)
    }
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    if let search = searchController.searchBar.text {
      filteredNotes = notes.filter { ($0.title ?? "").lowercased().contains(search.lowercased()) }
      tableView.reloadData()
    }
  }
  
  private func setupNavigationItem() {
    navigationItem.leftBarButtonItem = editButtonItem
    searchController.searchResultsUpdater = self
    searchController.searchBar.placeholder = "Search name"
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController
  }
  
}
