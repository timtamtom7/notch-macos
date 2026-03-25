import SwiftUI

struct MulticameraView: View {
    @StateObject private var multicamService = MulticameraService.shared
    @StateObject private var cameraService = CameraSettingsService.shared
    @State private var showAddAngleSheet = false

    var body: some View {
        VStack(spacing: 0) {
            // Layout picker
            HStack {
                Text("Layout")
                    .font(.subheadline)
                Picker("Layout", selection: $multicamService.layout) {
                    ForEach(MulticameraService.Layout.allCases, id: \.self) { layout in
                        Text(layout.displayName).tag(layout)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: multicamService.layout) { newLayout in
                    multicamService.setLayout(newLayout)
                }

                Spacer()

                Button(action: { showAddAngleSheet = true }) {
                    Label("Add Camera", systemImage: "plus")
                }
                .buttonStyle(.bordered)
            }
            .padding()

            Divider()

            // Camera views
            GeometryReader { geometry in
                cameraGrid(in: geometry.size)
            }
        }
        .sheet(isPresented: $showAddAngleSheet) {
            AddCameraAngleSheet(isPresented: $showAddAngleSheet)
        }
    }

    @ViewBuilder
    private func cameraGrid(in size: CGSize) -> some View {
        switch multicamService.layout {
        case .single:
            singleCamera(in: size)

        case .sideBySide:
            sideBySide(in: size)

        case .pictureInPicture:
            pipLayout(in: size)

        case .grid2x1:
            grid2x1(in: size)

        case .grid2x2:
            grid2x2(in: size)
        }
    }

    @ViewBuilder
    private func singleCamera(in size: CGSize) -> some View {
        if let active = multicamService.angles.first(where: { $0.isActive }) ?? multicamService.angles.first {
            cameraView(for: active)
        } else {
            emptyCameraPlaceholder
        }
    }

    @ViewBuilder
    private func sideBySide(in size: CGSize) -> some View {
        HStack(spacing: 4) {
            ForEach(multicamService.angles.prefix(2)) { angle in
                cameraView(for: angle)
                    .frame(width: size.width / 2 - 2)
            }
        }
    }

    @ViewBuilder
    private func pipLayout(in size: CGSize) -> some View {
        ZStack(alignment: .bottomTrailing) {
            // Main camera
            if let main = multicamService.angles.first(where: { $0.isActive }) ?? multicamService.angles.first {
                cameraView(for: main)
            }

            // PiP camera
            if multicamService.angles.count > 1 {
                let pip = multicamService.angles.first(where: { !$0.isActive }) ?? multicamService.angles[1]
                cameraView(for: pip)
                    .frame(width: size.width * 0.25, height: size.height * 0.25)
                    .cornerRadius(8)
                    .padding(8)
            }
        }
    }

    @ViewBuilder
    private func grid2x1(in size: CGSize) -> some View {
        VStack(spacing: 4) {
            ForEach(multicamService.angles.prefix(2)) { angle in
                cameraView(for: angle)
                    .frame(height: size.height / 2 - 2)
            }
        }
    }

    @ViewBuilder
    private func grid2x2(in size: CGSize) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 4) {
            ForEach(multicamService.angles.prefix(4)) { angle in
                cameraView(for: angle)
                    .frame(height: size.height / 2 - 2)
            }
        }
    }

    @ViewBuilder
    private func cameraView(for angle: MulticameraAngle) -> some View {
        ZStack {
            Color.black

            VStack {
                Image(systemName: "camera.fill")
                    .font(.largeTitle)
                    .foregroundColor(.secondary)
                Text(angle.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Overlay controls
            VStack {
                HStack {
                    Spacer()
                    Button(action: { multicamService.switchTo(angleId: angle.id) }) {
                        Image(systemName: angle.isActive ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(angle.isActive ? .green : .white)
                    }
                    .padding(4)
                }
                Spacer()
            }
        }
        .cornerRadius(8)
    }

    private var emptyCameraPlaceholder: some View {
        VStack {
            Image(systemName: "camera")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            Text("No cameras")
                .foregroundColor(.secondary)
            Button("Add Camera") {
                showAddAngleSheet = true
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct AddCameraAngleSheet: View {
    @Binding var isPresented: Bool
    @StateObject private var multicamService = MulticameraService.shared
    @StateObject private var cameraService = CameraSettingsService.shared
    @State private var name = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Add Camera Angle")
                .font(.headline)

            TextField("Angle Name", text: $name)
                .textFieldStyle(.roundedBorder)

            Text("Select Camera:")
                .font(.subheadline)

            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(cameraService.availableCameras) { camera in
                        Button(action: {
                            let angle = MulticameraAngle(
                                name: name.isEmpty ? camera.name : name,
                                cameraDeviceId: camera.id
                            )
                            multicamService.addAngle(angle)
                            isPresented = false
                            name = ""
                        }) {
                            HStack {
                                Text(camera.name)
                                Spacer()
                                Image(systemName: "plus.circle")
                            }
                            .padding()
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            Button("Cancel") {
                isPresented = false
            }
        }
        .padding()
        .frame(width: 300, height: 350)
        .onAppear {
            cameraService.refreshCameras()
        }
    }
}
