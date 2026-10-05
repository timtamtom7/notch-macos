# Notch

A camera and display utility for the menu bar notch — exposure, grid overlay, timecode.

## What it does

- Manual exposure
- grid overlay
- multicamera
- timecode
- battery widget

## Targets

- macOS menu bar

## Structure

Key types:

- ``NotchService``
- ``ExposureService`/`ManualExposureView``
- ``GridOverlayService``
- ``MulticameraService``
- ``TimecodeView``
- ``WeatherService``
- ``BatteryWidget``

Built around the notch itself rather than using it as a container.

## Status

Apple-platform experiment built to explore what an AI coding agent could produce for a native app. Not actively maintained.

Xcode projects here were generated with XcodeGen (`project.yml`) unless noted; open the `.xcodeproj` directly.
