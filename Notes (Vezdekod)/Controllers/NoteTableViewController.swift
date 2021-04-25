//
//  NoteTableViewController.swift
//  Notes (Vezdekod)
//
//  Created by Alex Yatsenko on 24.04.2021.
//

import UIKit

class NoteTableViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
  
  @IBOutlet private weak var pickerView: UIPickerView!
  @IBOutlet private weak var textView: UITextView!
  @IBOutlet private var tapRecognizer: UITapGestureRecognizer!
  @IBOutlet private weak var titleTextField: UITextField!
  @IBOutlet private weak var placeholderImageView: UIImageView!
  @IBOutlet private weak var clearButton: UIButton!
  @IBOutlet private weak var detailTitleLabel: UILabel!
  
  enum State {
    case create, detail, edit
  }
  private enum Category: String {
    case text, task, password
  }
  
  var state: State = .create
  var note: Note?
  
  private let categories: [Category] = [.task, .password, .text]
  private var selectedCategory = Category.task
  private let storageManager = StorageManager()
  private var isImageChanged = false
  
  @IBAction private func imagePressed(_ sender: UITapGestureRecognizer) {
    guard sender.state == .recognized else { return }
    let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
    let camera = UIAlertAction(title: "Camera", style: .default) { _ in
        self.chooseImagePicker(source: .camera)
    }
    camera.setValue(UIImage(systemName: "camera"), forKey: "image")
    camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    let photo = UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
        self.chooseImagePicker(source: .photoLibrary)
    })
    photo.setValue(UIImage(systemName: "photo"), forKey: "image")
    photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    
    let cancel = UIAlertAction(title: "Cancel", style: .cancel)
    cancel.setValue(UIImage(systemName: "xmark"), forKey: "image")
    cancel.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
    
    [camera, photo, cancel].forEach { actionSheet.addAction($0) }
    present(actionSheet, animated: true)
  }
  
  @IBAction func clearButtonPressed() {
    clearButton.isSelected = false
    placeholderImageView.image = #imageLiteral(resourceName: "placeholder")
    isImageChanged = false
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    if let note = note {
      if let title = note.title {
        self.title = title
        detailTitleLabel.text = title
        titleTextField.text = title
      } else {
        detailTitleLabel.text = nil
        titleTextField.text = nil
      }
      if let text = note.text {
        textView.text = text
      }
      if let index = categories.enumerated().first(where: { $0.element.rawValue == note.category })?.offset {
        pickerView.selectRow(index, inComponent: 0, animated: true)
      }
      if let imageData = note.image, let image = UIImage(data: imageData) {
        isImageChanged = true
        clearButton.isSelected = true
        placeholderImageView.image = image
      }
    }
    switch state {
    case .create, .edit:
      pickerView.isUserInteractionEnabled = true
      textView.isEditable = true
      tapRecognizer.isEnabled = true
      detailTitleLabel.isHidden = true
      titleTextField.isHidden = false
      clearButton.isHidden = false
      navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .save, target: self, action: #selector(savePressed)
      )
    case .detail:
      pickerView.isUserInteractionEnabled = false
      textView.resignFirstResponder()
      textView.isEditable = false
      tapRecognizer.isEnabled = false
      titleTextField.isHidden = true
      detailTitleLabel.isHidden = false
      clearButton.isHidden = true
      navigationItem.rightBarButtonItem = UIBarButtonItem(
        barButtonSystemItem: .edit, target: self, action: #selector(savePressed)
      )
    }
  }
  
  @objc private func savePressed() {
    titleTextField.resignFirstResponder()
    textView.resignFirstResponder()
    switch state {
    case .create:
      if titleTextField.hasText, let title = titleTextField.text {
        storageManager.saveNote(
          title: title,
          image: isImageChanged ? placeholderImageView.image?.pngData() : nil,
          category: selectedCategory.rawValue,
          text: textView.text) { [weak self] note in
          self?.state = .detail
          self?.setupUI()
        }
      }
    case .edit:
      if let note = note {
        note.title = titleTextField.text
        note.text = textView.text
        note.image = isImageChanged ? placeholderImageView.image?.pngData() : Data()
        note.category = selectedCategory.rawValue
        storageManager.edit(note: note) { [weak self] _ in
          self?.note = note
          self?.state = .detail
          self?.setupUI()
        }
      }
    case .detail:
      state = .edit
      setupUI()
    }
  }
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  numberOfRowsInComponent component: Int) -> Int {
    return categories.count
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  titleForRow row: Int,
                  forComponent component: Int) -> String? {
      return categories[row].rawValue
  }
  
  func pickerView(_ pickerView: UIPickerView,
                  didSelectRow row: Int,
                  inComponent component: Int) {
    selectedCategory = categories[row]
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
  
}

extension NoteTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  private func chooseImagePicker(source: UIImagePickerController.SourceType) {
    if UIImagePickerController.isSourceTypeAvailable(source) {
      let imagePicker = UIImagePickerController()
      imagePicker.delegate = self
      imagePicker.allowsEditing = true
      imagePicker.sourceType = source
      present(imagePicker, animated: true)
    }
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    
    if let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage {
      placeholderImageView.image = image
      clearButton.isSelected = true
      isImageChanged = true
    }
    picker.presentingViewController?.dismiss(animated: true)
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.presentingViewController?.dismiss(animated: true)
  }
}
