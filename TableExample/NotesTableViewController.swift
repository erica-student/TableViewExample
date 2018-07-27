import UIKit

class NotesTableViewController: UITableViewController, UITextFieldDelegate {
   // MARK: - Table View Data Source
  
  // Simple single section Table View
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  // One row per note
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return notes.count
  }
  
  // Populate each cell
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: NoteTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? NoteTableViewCell
    let row = indexPath.row
    cell.shareButton.tag = row // cheat
    guard row < notes.count
      else { fatalError("Expected note in range") }
    cell.textLabel?.text = notes[row]
    return cell
  }
  
  // MARK: - Table View Delegate
  
  // Enable "magic" swipe-to-delete
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    // Only handle deletions
    guard editingStyle == .delete else { return }
    
    // Update model then refresh view
    notes.remove(at: indexPath.row)
    tableView.reloadData()
    
    // Persistence
    UserDefaults.standard.set(notes, forKey: "notes")
  }
  
  // MARK: - Set Up
  
  override func viewDidLoad() {
    // Persistence
    notes = UserDefaults.standard.value(forKey: "notes") as? [String] ?? []
    
    // Smart note field button
    noteField.delegate = self
  }
  
  // MARK: - Model

  // Our main data
  var notes: [String] = []
  
  // Updating the model by saving a new note
  @IBAction func saveNote(_ sender: Any) {
    guard let note = noteField.text, !note.isEmpty
      else { return }
    notes.append(note)
    noteField.text = nil
    tableView.reloadData()
    UserDefaults.standard.set(notes, forKey: "notes")
  }
  
  // MARK: - Model Forwarded Actions
  
  // Allow users to share the contents of the note (using a common but ugly hack)
  // to connect a cell-based button with to the controller, and from there, the controller's model
  @IBAction func shareNote(_ sender: Any) {
    guard let button = sender as? UIView
      else { return }
    let note = notes[button.tag] // this is the hack
    let activityController = UIActivityViewController(activityItems: [note], applicationActivities: nil)
    present(activityController, animated: true)
  }
  
  // MARK: - TextField Delegate
  
  // A smart save button that's enabled only when there's text to save
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    // A non-empty replacement string, all is good
    if !string.isEmpty {
      saveButton.isEnabled = true
      return true
    }
    
    // Determine edited text
    let text = textField.text ?? ""
    let replacementText = (text as NSString).replacingCharacters(in: range, with: string) as String
    saveButton.isEnabled = !replacementText.isEmpty
    
    return true
  }
 
  // MARK: - UI Entries
  
  // Where the user enters the note
  @IBOutlet weak var noteField: UITextField!
  
  // Have a reference to enable/disable for the smart text field
  @IBOutlet weak var saveButton: UIButton!
  
}
