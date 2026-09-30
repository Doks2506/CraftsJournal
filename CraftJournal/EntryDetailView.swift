import SwiftUI

struct EntryDetailView: View {
    @ObservedObject var entry: CraftEntry

    @Environment(\.managedObjectContext) private var viewContext
    @State private var showingEdit = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {

                // Full photo
                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                }

                // Title
                Text(entry.title ?? "Untitled")
                    .font(.largeTitle)
                    .bold()

                // Craft type
                Text(entry.craftType ?? "")
                    .font(.title3)
                    .foregroundStyle(.secondary)

                // Artisan
                Text("Artisan: \(entry.artisanName ?? "Unknown")")
                    .font(.subheadline)

                // Date
                if let date = entry.date {
                    Text(date, style: .date)
                }

                // Notes
                Text(entry.notes ?? "")
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)

    
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showingEdit = true
                }
            }
        }

        .sheet(isPresented: $showingEdit) {
            EditEntryView(entry: entry)
                .environment(\.managedObjectContext, viewContext)
        }
    }
}
