# Expense Tracker (Android)

A modern, offline-first mobile application built with Flutter to track expenses, manage budgets, and analyze spending habits. Optimized for Android with a premium Material 3 design, seamless SQLite storage, and live interactive charts.

---

## 🌟 Key Features

*   **Complete Expense Management (CRUD)**: Add, edit, and delete transactions. Deletion is guarded by confirmation dialogs to prevent accidental loss.
*   **Detailed Analytics (Summary Dashboard)**: Displays an interactive ring style pie chart showing category breakdown percentages with a central total indicator, followed by linear progress breakdown bars.
*   **Custom Category Manager**: Allows creating and persisting custom categories on the fly with immediate validation.
*   **Collapsible Filters**: Filter expenses instantly by category or specific date ranges with real-time recalculation of total spending, transactions count, and top category.
*   **Theme Selector**: Sliding toggle in the app bar to switch dynamically between Light and Dark themes.
*   **Safe Input Validation**: Amount inputs are restricted to positive decimal numbers using custom keypad and format filters.
*   **Offline-First SQLite Cache**: Full persistent storage on Android.

---

## 🛠️ Technology Stack

*   **Framework**: Flutter & Dart
*   **Database**: SQLite (`sqflite`) for offline persistence
*   **State Management**: `ChangeNotifier` (ViewModel architecture)
*   **Visual Charts**: `pie_chart` package
*   **Styling**: Material 3 Design Guidelines

---

## 🚀 Getting Started

### Prerequisites

*   Flutter SDK (v3.10.8 or higher recommended)
*   Android Studio / VS Code with Dart & Flutter extensions
*   Android Emulator or Physical Android Device

### Installation

1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/BilalWattu521/B0626-Muhammad-Bilal-Ahmed-Innovaxel-Mobile-Developer-Intern.git
    cd expense_tracker
    ```

2.  **Install Dependencies**:
    ```bash
    flutter pub get
    ```

3.  **Run the Application**:
    ```bash
    flutter run
    ```

# Made by Muhammad Bilal Ahmed