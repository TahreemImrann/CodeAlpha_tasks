# CodeAlpha Task 4 — Quotify Random Quote Generator

## Overview

Quotify is a Flutter-based random quote application developed as part of my CodeAlpha App Development Internship. It presents motivational and inspirational quotes in a visually focused interface and allows users to discover, favorite, copy, and filter quotes.

## Features

- Random quote generation
- Quote and author display
- Category filtering
- All, Tech, Leadership, and Mindset categories
- Favorite/unfavorite quotes
- Saved/Favorites view
- Copy quote to clipboard
- Animated quote transitions
- Dynamic visual background
- Material 3 styled interface
- Haptic feedback for interactions
- Empty-state handling for saved quotes
- Local quote fallback when a remote quote request is unavailable

## Quote Categories

- All
- Tech
- Leadership
- Mindset

## API Integration

The application supports retrieving a random quote from a remote quote API when the **All** category is selected. Local quotes are retained as a fallback so the application can continue working if the network request fails.

## Technologies Used

- Flutter
- Dart
- Material 3
- HTTP / REST API integration
- JSON parsing
- Flutter Clipboard API

## How to Run

1. Make sure Flutter is installed.
2. Clone the repository.
3. Open the Task 4 project folder.
4. Install dependencies:

flutter pub get

5. Run:

flutter run

## Project Structure

Task-4-Random-Quote/
├── lib/
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md

## What I Learned

This task helped me practice API integration, JSON response handling, asynchronous programming, state updates, category filtering, clipboard functionality, animations, and designing a focused mobile-first user interface.

## Internship

**Program:** CodeAlpha App Development Internship  
