# MiniChatApp

A personal iOS learning project built with SwiftUI and Firebase. MiniChatApp supports one-to-one text conversations, user profiles, search, and unread message counts. The project explores observable state, asynchronous operations, Firestore listeners, and unit testing.

## Features

- **Authentication:** email/password registration, sign-in, sign-out, and password reset emails.
- **Personal chats:** live message updates, timestamps, latest-message previews, and conversations ordered by recent activity.
- **Unread messages:** a separate counter for each participant, badges in the chat list, and an Unread tab. Opening a conversation marks its messages as read.
- **User search:** partial, case-insensitive matching by name or publicly shared email. Empty and whitespace-only queries return no results.
- **Profiles:** editable name, bio, optional birthday, and an avatar selected from the photo library and uploaded to Firebase Storage.
- **Privacy settings:** controls for sharing email and birthday, with public and private profile documents stored separately.
- **Profile recovery:** an existing signed-in account can create missing profile documents without replacing documents that already exist.
- **Interface:** Home, Search, Unread, and Profile tabs; a gesture-driven side menu; theme and text-size preferences; and a chat composer with glass effects.

Message sending rejects blank text and blocks repeated sends while a request is in progress. After a successful send, the composer clears only if its text still matches the submitted draft. Pending server timestamps use local estimates when decoding messages.

## Stack

| Area | Technology |
| --- | --- |
| Interface | SwiftUI, PhotosUI, selected UIKit APIs |
| State and logic | `@Observable`, `@MainActor`, `async/await` |
| Authentication | Firebase Authentication |
| Chats and profiles | Cloud Firestore |
| Avatar storage | Firebase Storage |
| Dependencies | Swift Package Manager |
| Tests | Swift Testing (`@Test`, `#expect`) |

The code separates views, view models, data models, and Firebase services. `MessageComposerState` contains the local draft state and text validation.

## Getting started

The current project targets **iOS 26.5 or later** and is configured with **Xcode 27**. The Firebase package requirement starts at **12.14.0**, up to the next major version.

1. Clone this repository and open `MiniChatApp.xcodeproj` in Xcode.
2. Allow Xcode to resolve the Swift Package Manager dependencies.
3. Create a Firebase project and register an Apple app whose bundle identifier matches the app target. The repository currently uses `com.sobirjanovbobur.MiniChatApp`; use a matching Firebase registration if you change it.
4. Download your own `GoogleService-Info.plist`, place it in `MiniChatApp/`, and ensure it belongs to the **MiniChatApp** app target. This file is excluded from Git. See the [Firebase Apple setup guide](https://firebase.google.com/docs/ios/setup).
5. Enable **Email/Password** sign-in in Firebase Authentication. Set up **Cloud Firestore** and **Firebase Storage** in the same Firebase project.
6. Publish the contents of [firestore.rules](firestore.rules) and [storage.rules](storage.rules) in the corresponding Firebase Rules editors. Keeping these files in the repository does not deploy them.
7. For the chat-list query, create a collection-scoped composite index on `chats` with `participants` set to **Array contains** and `updatedAt` set to **Descending**. If Firestore reports a missing index, follow the link in its error message; see [Firestore index setup](https://firebase.google.com/docs/firestore/query-data/indexing).
8. Select the **MiniChatApp** scheme and an iPhone simulator, then run with **⌘R**. For a physical device, select your own signing team.

After registering, set a profile name so another account can find you. To try messaging, use two accounts on separate devices or simulators, find the other user in Search, and open a conversation.

## Project layout

```text
MiniChatApp/
├── MiniChatAppApp.swift          # App entry point and Firebase initialization
├── ContentView.swift            # Authentication and profile-loading flow
└── App/
    ├── Model/                   # User, profile, chat, and preference models
    ├── Service/                 # ChatService and ProfileService
    ├── ViewModel/               # Authentication, chat, search, profile, settings
    └── View/
        ├── Auth/                # Login and registration
        ├── Chat/                # Chat list and conversation screen
        ├── Tabs/                # Main tabs, search, and profile
        └── Components/          # Shared UI and composer state
MiniChatAppTests/                 # Three test suites in one test target
```

## Firebase data layout

| Path | Contents |
| --- | --- |
| `users/{uid}` | Name, bio, avatar URL, and optional publicly shared email/birthday |
| `users/{uid}/private/profile` | Birthday and visibility preferences; access restricted to the owner |
| `chats/{chatId}` | Two participants, last message, update time, and `unreadCounts` keyed by UID |
| `chats/{chatId}/messages/{messageId}` | Sender, receiver, text, chat ID, and creation time |
| Storage: `profile_images/{uid}.jpg` | User avatar |

Chat IDs are formed from the two sorted user IDs joined with an underscore. Sending a message writes the message and updates the chat summary in one batch. Message listening starts after the parent chat exists, including when the other participant sends the first message.

Public profiles are readable by signed-in users. The app exposes another user's email to search only when it is present in their public profile. Older database records may still contain legacy fields; this repository does not include an automatic migration for existing data.

The rules restrict chat access to participants and avatar writes to the owner. Chat summaries and unread counts are still updated by the client; the rules do not validate every summary change against a matching message. Firebase rule behavior is not covered by the unit tests below. [FIREBASE_RULES.md](FIREBASE_RULES.md) contains earlier development notes, some of which predate the current profile and chat changes.

## Tests

There are **20 Swift Testing tests** in the single `MiniChatAppTests` target:

| Suite | Tests | Coverage |
| --- | ---: | --- |
| `MessageComposerStateTests` | 10 | Empty/whitespace input, ordinary text, emoji, trimming, and clearing draft text |
| `ChatModelTests` | 4 | Missing or empty counters, an absent user, and independent participant counts |
| `UserSearchViewModelTests` | 6 | Empty queries, whitespace, partial names, letter case, email matches, and no matches |

With Firebase configured as described above, select **MiniChatApp** and press **⌘U**, or run an individual test using the button beside its declaration. Add new test files to the existing `MiniChatAppTests` target rather than creating another target for each file.

The shared scheme disables parallel test-target execution to avoid multiple simulator copies. These are app-hosted tests, so Xcode still launches the app and initializes Firebase. The assertions check local logic; they do not test Firebase delivery, access rules, or the full interface.

Latest verified local run: **20 passed, 0 failed, 0 skipped** on an iPhone 18 Pro simulator with iOS 27.0, on October 13, 2026.

## Current scope

- Messaging currently supports text only. Image selection exists in composer state, but sending chat attachments is not implemented.
- The profile's **Mute / Unmute** button changes local UI state only; push notifications and notification muting are not implemented.
- **Search** in the profile header is a placeholder. User search works in the Search tab.
- **Delete Account** displays a not-yet-implemented message. Chat/message deletion and message editing are not exposed in the interface.
- The **Online** label is decorative; there is no live presence tracking.
- Appearance preferences are available, but the conversation screen currently uses a fixed dark appearance.
- Search loads other users before filtering locally, and message history is loaded without pagination. These choices suit the current learning scope.

Possible next steps are tests for asynchronous send/listener behavior, Firebase rules tests, and pagination as the amount of data grows.
