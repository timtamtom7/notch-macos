import SwiftUI

struct StreamingSettingsView: View {
    @StateObject private var streamingService = StreamingService.shared
    @State private var showAddSheet = false
    @State private var newName = ""
    @State private var newType: StreamingDestination.DestinationType = .youtube
    @State private var newServerURL = ""
    @State private var newStreamKey = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Streaming Destinations")
                    .font(.headline)
                Spacer()
                Button(action: { showAddSheet = true }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }

            if streamingService.destinations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tv.and.mediabox")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No streaming destinations")
                        .foregroundColor(.secondary)
                    Text("Add a destination to stream live")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button("Add Destination") {
                        showAddSheet = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(streamingService.destinations) { destination in
                            destinationRow(destination)
                        }
                    }
                }
            }
        }
        .padding()
        .sheet(isPresented: $showAddSheet) {
            addDestinationSheet
        }
    }

    @ViewBuilder
    private func destinationRow(_ destination: StreamingDestination) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(destination.name)
                    .font(.system(size: 13, weight: .medium))
                Text(destination.type.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            if streamingService.activeDestination?.id == destination.id {
                Text("LIVE")
                    .font(.caption2.bold())
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.red)
                    .cornerRadius(4)
            }

            Button(action: {
                Task {
                    try? await streamingService.connect(to: destination)
                }
            }) {
                Image(systemName: "antenna.radiowaves.left.and.right")
            }
            .buttonStyle(.bordered)
            .help("Start streaming")

            Button(action: { streamingService.removeDestination(id: destination.id) }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }

    private var addDestinationSheet: some View {
        VStack(spacing: 16) {
            Text("Add Streaming Destination")
                .font(.headline)

            Form {
                TextField("Name", text: $newName)

                Picker("Type", selection: $newType) {
                    ForEach(StreamingDestination.DestinationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .onChange(of: newType) { newType in
                    if newServerURL.isEmpty {
                        switch newType {
                        case .youtube: newServerURL = "rtmp://a.rtmp.youtube.com/live2"
                        case .twitch: newServerURL = "rtmp://live.twitch.tv/app"
                        case .vimeo: newServerURL = "rtmp://live.twitch.tv/app"
                        case .custom: newServerURL = ""
                        }
                    }
                }

                TextField("Server URL", text: $newServerURL)
                    .textFieldStyle(.roundedBorder)

                SecureField("Stream Key", text: $newStreamKey)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Cancel") {
                    showAddSheet = false
                    clearForm()
                }
                Button("Add") {
                    let destination = StreamingDestination(
                        id: UUID(),
                        name: newName,
                        type: newType,
                        serverURL: newServerURL,
                        streamKey: newStreamKey,
                        isActive: false
                    )
                    streamingService.addDestination(destination)
                    showAddSheet = false
                    clearForm()
                }
                .buttonStyle(.borderedProminent)
                .disabled(newName.isEmpty || newServerURL.isEmpty)
            }
        }
        .padding()
        .frame(width: 400)
    }

    private func clearForm() {
        newName = ""
        newServerURL = ""
        newStreamKey = ""
    }
}
