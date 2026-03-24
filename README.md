# 🏥 Smart Health Product Scanner

A comprehensive Flutter application that scans product barcodes, analyzes nutritional information, and provides AI-powered health insights using Google Gemini API and OpenFoodFacts database.

## ✨ Features

### 🔐 Authentication
- **Google Sign-in Integration**: Seamless login with Google account
- **Firebase Authentication**: Secure user authentication and management
- **Auto-logout**: Session management with automatic logout on app restart

### 📱 Product Scanning
- **Barcode Scanner**: Real-time barcode/QR code scanning with mobile_scanner
- **Product Information**: Fetch detailed product data from OpenFoodFacts API
- **Scan History**: Keep track of all scanned products with timestamps
- **Product Details**: Display nutritional facts, ingredients, allergens, and more

### 🧠 Health Analysis
- **AI-Powered Analysis**: Google Gemini integration for personalized health insights
- **Nutritional Breakdown**: Detailed analysis of proteins, fats, carbohydrates, vitamins, and minerals
- **Health Recommendations**: Personalized suggestions based on product analysis
- **Multiple Analysis Views**: Different perspectives on health impact

### ❤️ Health Tracking
- **Personal Health Metrics**: Track weight, blood pressure, and other vital signs
- **Health History**: View trends and historical data
- **Health Insights**: AI-generated recommendations based on your profile

### 🎯 Wishlist
- **Save Products**: Add products to your wishlist for future reference
- **Manage Wishlist**: Organize and manage saved products
- **Quick Access**: Easy access to frequently checked products

### 👤 User Profile
- **Profile Management**: Update personal information and health details
- **Preference Settings**: Customize app preferences and notifications
- **Data Privacy**: Secure storage of personal information in Firestore

## 🛠 Tech Stack

### Frontend
- **Flutter** 3.7.0+ - Cross-platform mobile framework
- **Provider** 6.1.2 - State management
- **GetIt** 7.7.0 - Service locator/Dependency Injection

### Backend & Services
- **Firebase Core** 3.15.2 - Firebase initialization
- **Firebase Authentication** 5.3.1 - User authentication
- **Cloud Firestore** 5.0.1 - Real-time database
- **Google Sign-in** 6.2.1 - OAuth authentication
- **Google Generative AI** 0.3.0 - Gemini API for health analysis

### APIs & Libraries
- **OpenFoodFacts** 3.29.0 - Product database and nutritional information
- **Flutter Dotenv** 5.1.0 - Environment variables management
- **Mobile Scanner** - Barcode and QR code scanning

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- Flutter SDK: 3.7.0 or higher
- Dart SDK: 3.7.0 or higher
- Android Studio or Xcode (for mobile development)
- Git

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/PDA2105/smart-health-product-scanner.git
cd smart_health_product_scanner
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Environment Variables Setup

Create a `.env` file in the project root:
```bash
touch .env
```

Add the following environment variables to `.env`:
```env
GEMINI_API_KEY=your_google_gemini_api_key_here
```

- Get Gemini API key from [Google AI Studio](https://makersuite.google.com/app/apikey)

### 4. Firebase Setup

#### For Android:
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one
3. Add Android app - use package name: `com.example.smart_health_product_scanner`
4. Download `google-services.json` and place it in `android/app/`
5. The `GoogleService-Info.plist` is already configured for iOS

#### For iOS:
1. The iOS Firebase configuration is pre-configured
2. Run `flutter pub get` to generate native iOS files
3. Pod dependencies will be installed automatically

### 5. Google Sign-in Configuration

#### Android:
1. Get your SHA-1 fingerprint:
   ```bash
   ./gradlew signingReport
   ```
2. Add Android app in Firebase Console with the SHA-1 fingerprint
3. Enable Google Sign-in in Firebase Console

#### iOS:
1. Configure OAuth consent screen in Google Cloud Console
2. Add iOS app with Bundle ID: `com.example.smartHealthProductScanner`
3. Download OAuth client ID for iOS

### 6. Run the App

**Development:**
```bash
flutter run -d <device_id>
```

**Release Build:**
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── core/
│   ├── config/              # Configuration files (Gemini config, etc.)
│   ├── constants/           # App constants
│   ├── services/            # Core services (health analysis, etc.)
│   ├── theme/               # App theme and styles
│   ├── utils/               # Utility functions
│   └── widgets/             # Reusable widgets
├── data/
│   ├── datasources/         # Remote data sources
│   ├── models/              # Data models
│   └── repositories/        # Data repositories
├── features/
│   ├── auth/                # Authentication feature
│   ├── health_tracking/     # Health tracking feature
│   ├── product/             # Product management feature
│   ├── profile/             # User profile feature
│   ├── scan/                # Barcode scanning feature
│   └── wishlist/            # Wishlist feature
├── routes/
│   ├── app_routes.dart      # Route definitions
│   └── routes/              # Route files
├── services/                # Business logic services
└── shared/
    ├── dialogs/             # Shared dialogs
    └── widgets/             # Shared widgets
```

## 🏗 Architecture

The app follows **Clean Architecture** principles:

- **Presentation Layer**: UI components, pages, and providers
- **Domain Layer**: Business logic and use cases
- **Data Layer**: Data sources, repositories, and models
- **Core Layer**: Common utilities, themes, and configurations

## 📱 Features in Detail

### Product Scanning & Analysis
1. User opens the scanner
2. Barcode/QR code is detected
3. Product data is fetched from OpenFoodFacts
4. Gemini AI analyzes the product
5. Health insights are displayed
6. User can save to wishlist or view history

### Health Tracking
- Users can log daily health metrics
- AI provides personalized recommendations
- Historical data is visualized for trend analysis

### Wishlist Management
- Save products for later
- Quick comparison between products
- Export wishlist functionality

## 🔒 Security & Privacy

- **Firebase Security**: Cloud Firestore security rules protect user data
- **Environment Variables**: Sensitive API keys stored in `.env` file (not committed)
- **OAuth 2.0**: Secure Google authentication
- **Data Encryption**: Firebase ensures data is encrypted in transit and at rest

## 🧪 Testing

Run unit tests:
```bash
flutter test
```

Run integration tests:
```bash
flutter test integration_test/
```

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support, email duyan@example.com or open an issue on GitHub.

## 🙏 Acknowledgments

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [OpenFoodFacts API](https://github.com/openfoodfacts)
- [Google Gemini API](https://ai.google.dev/)

---

**Made with ❤️ by Smart Health Team**
