# Flutter User Directory

This is my lab project for ITT632 Mobile Cloud Computing. It is a Flutter app that gets user information from JSONPlaceholder and displays it in a list. I used Android Studio as the IDE.

The project demonstrates how a mobile app requests data from a remote server, reads the JSON response and displays the information on screen.

## What the app does

The home screen shows 10 users with their names, email addresses and websites. Website is the extra field assigned to me because my matric number ends with 9.

Tapping a user opens their full details, including their phone number, address and company information. The app also includes:

- Search and alphabetical sorting
- Pull-to-refresh
- Loading and error screens
- A Retry button when a request fails
- An option to copy contact details

## API used

https://jsonplaceholder.typicode.com/users

The user data is fetched from the API when the app runs. It is not saved as a local JSON file.

## Running the project

Clone the repository:

```bash
git clone https://github.com/sboff-tech/Flutter-User-Directory-Application-.git
cd Flutter-User-Directory-Application-
flutter pub get
```

Open the project in Android Studio, select an Android emulator or connected phone, and run `lib/main.dart`.

You can also run it from the terminal:

```bash
flutter run
```

An internet connection is needed to load the users.

## Code overview

The code is separated into models, services, screens and shared widgets. The service handles the HTTP request, while the model classes read the user, address and company data.

The request Future is stored in `initState()` so that rebuilding the screen does not send the same request again.

## Checks

```bash
flutter analyze
flutter test
```

To try the error screen, turn off the device’s internet connection and refresh the list. Reconnect and tap Retry to load the users again.

## Student

Wan Syazrin  
2025197599  
ITT632 – Mobile Cloud Computing
