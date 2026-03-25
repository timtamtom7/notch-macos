import SwiftUI

struct NotchSettingsView: View {
    @StateObject private var cameraService = CameraSettingsService.shared
    @StateObject private var recordingService = NotchRecordingService.shared

    var body: some View {
        VStack(spacing: 16) {
            Text("Camera & Recording")
                .font(.headline)

            Form {
                // Camera selection
                Picker("Camera", selection: $cameraService.settings.deviceId) {
                    Text("Select Camera").tag("")
                    ForEach(cameraService.availableCameras) { camera in
                        HStack {
                            Text(camera.name)
                            if camera.supports4K {
                                Text("4K")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tag(camera.id)
                    }
                }
                .labelsHidden()
                .onChange(of: cameraService.settings.deviceId) { _ in
                    cameraService.saveSettings()
                }

                Button("Refresh Cameras") {
                    cameraService.refreshCameras()
                }

                Divider()

                // Resolution
                Picker("Resolution", selection: $cameraService.settings.resolution) {
                    ForEach(CameraSettings.Resolution.allCases, id: \.self) { res in
                        Text(res.rawValue).tag(res)
                    }
                }
                .labelsHidden()
                .onChange(of: cameraService.settings.resolution) { _ in
                    cameraService.saveSettings()
                }

                // Frame rate
                Picker("Frame Rate", selection: $cameraService.settings.frameRate) {
                    Text("24 fps").tag(24)
                    Text("30 fps").tag(30)
                    Text("60 fps").tag(60)
                    Text("120 fps").tag(120)
                }
                .labelsHidden()
                .onChange(of: cameraService.settings.frameRate) { _ in
                    cameraService.saveSettings()
                }

                Divider()

                // HDR
                Toggle("Enable HDR", isOn: $cameraService.settings.enableHDR)
                    .onChange(of: cameraService.settings.enableHDR) { _ in
                        cameraService.saveSettings()
                    }

                // Exposure
                HStack {
                    Text("Exposure:")
                    Slider(value: $cameraService.settings.exposureCompensation, in: -2...2, step: 0.1)
                    Text(String(format: "%.1f", cameraService.settings.exposureCompensation))
                        .frame(width: 40)
                }
                .onChange(of: cameraService.settings.exposureCompensation) { _ in
                    cameraService.saveSettings()
                }

                // White balance
                Picker("White Balance", selection: $cameraService.settings.whiteBalance) {
                    ForEach(CameraSettings.WhiteBalanceMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
                .onChange(of: cameraService.settings.whiteBalance) { _ in
                    cameraService.saveSettings()
                }

                // Focus
                Picker("Focus", selection: $cameraService.settings.focusMode) {
                    ForEach(CameraSettings.FocusMode.allCases, id: \.self) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .labelsHidden()
                .onChange(of: cameraService.settings.focusMode) { _ in
                    cameraService.saveSettings()
                }

                // Zoom
                HStack {
                    Text("Zoom:")
                    Slider(value: $cameraService.settings.zoomFactor, in: 1...10, step: 0.1)
                    Text(String(format: "%.1fx", cameraService.settings.zoomFactor))
                        .frame(width: 50)
                }
                .onChange(of: cameraService.settings.zoomFactor) { _ in
                    cameraService.saveSettings()
                }
            }
        }
        .padding()
        .onAppear {
            cameraService.refreshCameras()
        }
    }
}
