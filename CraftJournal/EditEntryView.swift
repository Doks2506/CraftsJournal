import SwiftUI

struct EditEntryView: View {
    @ObservedObject var entry: CraftEntry

    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var title: String
    @State private var craftType: String
    @State private var notes: String
    @State private var artisanName: String

    init(entry: CraftEntry) {
        self.entry = entry

        _title = State(initialValue: entry.title ?? "")
        _craftType = State(initialValue: entry.craftType ?? crafts[0])
        _notes = State(initialValue: entry.notes ?? "")
        _artisanName = State(initialValue: entry.artisanName ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Title", text: $title)

                Picker("Craft", selection: $craftType) {
                    ForEach(crafts, id: \.self) { craft in
                        Text(craft)
                    }
                }

                TextField("Artisan Name", text: $artisanName)

                TextField("Notes", text: $notes, axis: .vertical)
                
            }
            .navigationTitle("Edit Entry")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveChanges()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func saveChanges() {
        entry.title = title
        entry.craftType = craftType
        entry.artisanName = artisanName
        entry.notes = notes

        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Could not update entry: \(error)")
        }
    }
}
