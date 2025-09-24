# Finance Tracker Implementation

This project is a simple finance tracking application built with Flutter. The main focus was on implementing core functionality for tracking transactions and exchange rates.

## Project Structure

- `lib/`
  - `presentation/` - UI components and screens
  - `domain/` - Business logic and entities
  - `data/` - Data sources and repositories
  - `core/` - Shared utilities and constants

## Key Features Implemented

1. **Transaction Management**
   - Display list of transactions
   - Show transaction details including exchange rates
   - Basic transaction filtering

2. **Exchange Rate Tracking**
   - Display current exchange rates
   - Basic currency conversion

3. **State Management**
   - Used Provider for state management
   - Implemented TransactionProvider for transaction state

## Dependencies

- flutter: UI framework
- provider: State management
- intl: Date and number formatting
- http: API calls

## Setup

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter run`

## Notes

- This was implemented as a test project
- Focus was on core functionality rather than UI polish
- Some features may be incomplete or placeholders
