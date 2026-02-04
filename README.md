# ⚽ Futsmandu

**Futsmandu** is the ultimate digital ecosystem for Futsal enthusiasts. Designed to streamline the experience for players, court owners, and system administrators, it brings the game of Futsal into the palm of your hand.

[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![State management](https://img.shields.io/badge/State-Provider-blue)](https://pub.dev/packages/provider)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 🚀 Overview

Futsmandu solves the common hurdles in the Futsal community: from finding a court at peak hours to gathering enough players for a match. With a robust Role-Based Access Control (RBAC) system, the app provides tailored experiences for three distinct users:

### 👤 1. Players (The Athletes)
- **Find Matches**: Browse nearby Futsal venues with real-time availability.
- **Solo Join**: Don't have a team? Join public bookings as a solo player.
- **Team Recruitment**: Find teams looking for players or post a request for your own team.
- **Easy Booking**: Quick and seamless court booking process.

### 🏟️ 2. Futsal Owners (The Entrepreneurs)
- **Booking Management**: Accept or reject booking requests in real-time.
- **Analytics Dashboard**: Visualize business performance with detailed charts and metrics.
- **Venue Control**: Manage court schedules, pricing, and amenities.
- **KYC Verification**: Secure onboarding and identity verification.

### 🛡️ 3. Admin (The Orchestrator)
- **System Oversight**: Monitor platform activity and user growth.
- **User Management**: Manage player and owner accounts.
- **Platform Analytics**: High-level insights into the entire ecosystem.

---

## 📱 App Walkthrough

### 🏃 Player Experience
| Search & Browse | Venue Details | Booking Flow | Join Team |
| :---: | :---: | :---: | :---: |
| ![player-1](https://github.com/user-attachments/assets/fe0724e1-66b4-4366-b9da-84e019c7695f) | ![player2](https://github.com/user-attachments/assets/f1448de5-6351-4960-8e61-532f863202fc) | ![player3](https://github.com/user-attachments/assets/383c20f8-e0b1-4611-ae3b-159ed8ff32a0) | ![player4](https://github.com/user-attachments/assets/ed3c202e-a10f-47d5-b456-4aec978f125a) |

| Profile & Stats | Match History | Solo Join | Discovery |
| :---: | :---: | :---: | :---: |
| ![player6](https://github.com/user-attachments/assets/95499021-f3b2-4c52-8625-32a992b2c171) | ![player7](https://github.com/user-attachments/assets/78ab7eda-0e9f-4d9e-9e7e-1d0c505180f2) | ![player8](https://github.com/user-attachments/assets/c19d7f55-4c43-4a32-89f1-eb2dda8dfb59) | ![player9](https://github.com/user-attachments/assets/9e48ae7b-eede-46c7-be85-454085906bd9) |

### 📊 Owner Dashboard
| Analytics Charts | Booking Requests | KYC Process | Venue Management |
| :---: | :---: | :---: | :---: |
| ![owner1](https://github.com/user-attachments/assets/af8732c7-081e-44fd-a28d-1adb2e45502c) | ![owner-booking-1](https://github.com/user-attachments/assets/5c363ae5-ac2c-41be-b1ac-77fe3b609aba) | ![owner-kyc1](https://github.com/user-attachments/assets/80936967-df00-46e0-8d8c-8ef632ddade7) | ![owner2](https://github.com/user-attachments/assets/d8ec37bd-6ab7-4e53-af27-2b4fe788ba38) |

### 🛠️ Admin Control
| User Management | Revenue Stats | System Logs | Platform Metrics |
| :---: | :---: | :---: | :---: |
| ![admin1](https://github.com/user-attachments/assets/4ce0c4e2-bc6b-4c81-bbf0-099fb2527de6) | ![admin2](https://github.com/user-attachments/assets/524bd42b-f2f5-45bb-91e2-81740b4692d9) | ![admin3](https://github.com/user-attachments/assets/33165574-8c1d-49bc-9655-abd5615efb9e) | ![admin4](https://github.com/user-attachments/assets/128f4ba4-6891-4d82-93f6-506bb17c8d5c) |

---

## 🛠️ Tech Stack

- **Frontend**: Flutter (for iOS, Android, and Web)
- **State Management**: [Provider](https://pub.dev/packages/provider)
- **Navigation**: [GoRouter](https://pub.dev/packages/go_router)
- **Networking**: [Dio](https://pub.dev/packages/dio)
- **Local Storage**: [Shared Preferences](https://pub.dev/packages/shared_preferences)
- **UI Design**: Material Design 3, Rubik & OpenSans Fonts

---

## 🏗️ Architecture

The project follows a modular and clean structure:
- **Models**: Data structures for Users, Venues, and Bookings.
- **Providers**: Encapsulated state management logic.
- **Services**: Abstracted API and Storage interactions.
- **Screens**: Clean UI implementation following role-based views.

---

## ⚙️ Getting Started

1. **Clone the repository**:
   ```bash
   git clone https://github.com/nirajandhungel/futsmandu-app.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Run the app**:
   ```bash
   flutter run
   ```

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---

Developed with ❤️ by [Nirajan Dhungel](https://github.com/nirajandhungel)
