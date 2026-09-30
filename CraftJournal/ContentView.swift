import SwiftUI
import CoreData

struct ContentView: View {

    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [
            NSSortDescriptor(
                keyPath: \CraftEntry.date,
                ascending: false
            )
        ],
        animation: .default
    )
    private var entries: FetchedResults<CraftEntry>

    @State private var showingAddEntry = false

    // C2 - Search
    @State private var searchText = ""

    // C3 - Sort
    @State private var sortAscending = false

    // Filter + sort the entries
    private var displayedEntries: [CraftEntry] {
        let filtered = entries.filter { entry in
            searchText.isEmpty ||
            (entry.title ?? "")
                .localizedCaseInsensitiveContains(searchText)
        }

        return filtered.sorted { first, second in
            let firstDate = first.date ?? .distantPast
            let secondDate = second.date ?? .distantPast

            if sortAscending {
                return firstDate < secondDate
            } else {
                return firstDate > secondDate
            }
        }
    }

    var body: some View {

        NavigationStack {

            List {

                if displayedEntries.isEmpty {

                    if searchText.isEmpty {

                        ContentUnavailableView(
                            "No Craft Entries",
                            systemImage: "book.closed",
                            description: Text(
                                "Tap + to add your first craft journal entry."
                            )
                        )

                    } else {

                        ContentUnavailableView(
                            "No Results",
                            systemImage: "magnifyingglass",
                            description: Text(
                                "No entries match your search."
                            )
                        )
                    }

                } else {

                    ForEach(displayedEntries) { entry in

                        NavigationLink {
                            EntryDetailView(entry: entry)
                        } label: {
                            EntryRow(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteEntries)
                }
            }

            // C2 - Search bar
            .searchable(
                text: $searchText,
                prompt: "Search by title"
            )

            .toolbar {

                // existing title + entry count
                ToolbarItem(placement: .principal) {
                    VStack(spacing: 2) {

                        Text("Craft Journal")
                            .font(.headline)

                        Text(
                            "\(entries.count) \(entries.count == 1 ? "entry" : "entries")"
                        )
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                }

                // C3 - Sort menu
                ToolbarItem(placement: .topBarLeading) {
                    Menu {

                        Button {
                            sortAscending = false
                        } label: {
                            Label(
                                "Newest First",
                                systemImage: sortAscending
                                    ? "circle"
                                    : "checkmark.circle"
                            )
                        }

                        Button {
                            sortAscending = true
                        } label: {
                            Label(
                                "Oldest First",
                                systemImage: sortAscending
                                    ? "checkmark.circle"
                                    : "circle"
                            )
                        }

                    } label: {
                        Label(
                            "Sort",
                            systemImage: "arrow.up.arrow.down"
                        )
                    }
                }

                //  existing Add button
                ToolbarItem(placement: .topBarTrailing) {

                    Button {
                        showingAddEntry = true
                    } label: {
                        Label("Add", systemImage: "plus")
                    }
                }
            }

            .sheet(isPresented: $showingAddEntry) {

                AddEntryView()
                    .environment(
                        \.managedObjectContext,
                        viewContext
                    )
            }
        }
    }

    private func deleteEntries(offsets: IndexSet) {

        withAnimation {

            for index in offsets {
                let entry = displayedEntries[index]
                viewContext.delete(entry)
            }

            do {
                try viewContext.save()
            } catch {
                print("Could not delete: \(error)")
            }
        }
    }
}



struct EntryRow: View {

    @ObservedObject var entry: CraftEntry

    var body: some View {

        HStack {

            if let data = entry.photo,
               let uiImage = UIImage(data: data) {

                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 8)
                    )

            } else {

                Image(systemName: "photo")
                    .frame(width: 60, height: 60)
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading) {

                Text(entry.title ?? "Untitled")
                    .font(.headline)

                Text(entry.craftType ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(entry.artisanName ?? "")
                    .font(.caption)
            }
        }
    }
}


#Preview {

    ContentView()
        .environment(
            \.managedObjectContext,
            PersistenceController.preview.container.viewContext
        )
}
