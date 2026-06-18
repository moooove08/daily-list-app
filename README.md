# Daily List

Daily List is a small UIKit checklist app for creating personal lists, reusing templates, customizing list icons/colors, and archiving completed checklists.

## Features

- Create, edit, and delete checklists.
- Add, edit, check, and delete checklist items.
- Automatically archive a list when all items are completed.
- Browse archived lists.
- Create lists from built-in and user-saved templates.
- Customize list icon and accent color.
- Switch between multiple visual themes.
- Persist lists, templates, archive, and theme selection with `UserDefaults`.

## Tech Stack

- Swift
- UIKit
- Xcode project
- `UITableView`-based screens
- `UserDefaults` + `Codable` persistence
- SF Symbols for icons

## Project Structure

```text
checklist/
  App/                  App entry point and root navigation
  Components/           Reusable UI components
  Models/               Codable app models
  Screens/              Feature screens grouped by app area
  Storage/              Local archive storage
  Templates/            Checklist template data
  Theme/                App themes and color helpers
  Assets.xcassets       App icons and image assets
  Base.lproj            Launch screen
```

## Run Locally

1. Open `daily-list-app.xcodeproj` in Xcode.
2. Select the `daily-list-app` scheme.
3. Choose an iPhone simulator or device.
4. Build and run.

The current project targets iOS 17.6+.

## Portfolio Notes

This project is suitable for a junior iOS portfolio if it is presented as a compact UIKit productivity app. It demonstrates programmatic UIKit layout, table-driven editing flows, simple persistence, theming, reusable templates, and state handling around list/archive updates.

For a stronger portfolio presentation, add 3-5 screenshots, a short demo video, and a short "What I improved" section describing the index-safety fixes in checklist editing.

## Current Limitations

- Persistence uses `UserDefaults`, which is fine for a small demo but not ideal for large data sets.
- There are no automated UI or unit tests yet.
- The UI is mostly programmatic UIKit and intentionally lightweight.

