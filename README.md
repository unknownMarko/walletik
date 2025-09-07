# Walletik 💳

A Flutter loyalty cards wallet app that lets you store and manage your loyalty cards digitally.

## Features

- 📱 **Digital Card Storage** - Store loyalty cards without the physical plastic
- 🎨 **Dark Theme** - Beautiful dark UI with custom color scheme
- 📲 **Add Cards** - Simple form to add shop name and card number
- ⚙️ **Settings** - Configure app preferences, security, and view app info
- 📱 **Multi-Platform** - Supports Android, iOS, Web, Windows, macOS, and Linux

## Current Status

🚧 **In Development** - Basic navigation and UI structure completed

### Completed
- ✅ Bottom navigation with swipe support
- ✅ Cards screen with add card functionality
- ✅ Add card form with shop name and card number
- ✅ Settings screen with sections for Appearance, Security, About, Help, and Usage Stats
- ✅ Dark theme with custom colors

### Planned Features
- Card display (grid/list view)
- Barcode/QR code generation and scanning
- Card categories and organization
- Biometric security
- Data backup and export

## Getting Started

1. Install Flutter SDK
2. Clone this repository
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the app

## Project Structure

```
lib/
├── main.dart           # App entry point and navigation
├── screens/           # Individual screen widgets
│   ├── cards_screen.dart    # Main cards list screen
│   ├── add_card_screen.dart # Add new card form
│   └── settings_screen.dart # App settings
└── models/            # Data models (planned)
    └── loyalty_card.dart
```
