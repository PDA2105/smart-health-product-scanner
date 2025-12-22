# KẾ HOẠCH PHÁT TRIỂN DỰ ÁN FLUTTER (1--2 THÁNG)

Tên dự án: Smart Health Product Scanner  
  
Mô tả:  
Ứng dụng Flutter cho phép quét mã sản phẩm (Barcode/QR) hoặc nhận diện
bằng hình ảnh,  
hiển thị thông tin chi tiết (thành phần, dinh dưỡng),  
AI đánh giá mức độ an toàn cho sức khỏe (thang điểm 0--10),  
kết hợp chiều cao -- cân nặng người dùng để cá nhân hóa đánh giá,  
đề xuất sản phẩm phù hợp hơn và hỗ trợ định hướng giảm cân / tăng cân.

## 1. Mục tiêu dự án {#mục-tiêu-dự-án}

\- Xây dựng ứng dụng Flutter hoàn chỉnh theo chuẩn thực tế  
- Tích hợp Firebase (Auth, Firestore, Storage)  
- Ứng dụng AI vào phân tích sức khỏe  
- Cá nhân hóa trải nghiệm theo thể trạng người dùng  
- Dự án đủ WOW cho CV và Portfolio

## 2. Ý tưởng mới tích hợp {#ý-tưởng-mới-tích-hợp}

\- Người dùng nhập: chiều cao, cân nặng, giới tính, mục tiêu (giảm cân /
tăng cân / giữ cân)  
- Ứng dụng tính chỉ số BMI và phân loại thể trạng  
- AI đánh giá sản phẩm dựa trên:  
+ Thành phần  
+ Giá trị dinh dưỡng  
+ Thể trạng cá nhân  
- Đề xuất lộ trình dinh dưỡng theo mục tiêu sức khỏe

## 3. Chức năng chính {#chức-năng-chính}

1\. Đăng ký / Đăng nhập (Firebase Auth)  
2. Nhập hồ sơ sức khỏe cá nhân  
3. Quét mã sản phẩm (Barcode/QR)  
4. Upload ảnh để nhận diện sản phẩm  
5. Hiển thị thông tin chi tiết sản phẩm  
6. Phân tích thành phần & cảnh báo  
7. AI chấm điểm sức khỏe (0--10)  
8. Gợi ý sản phẩm thay thế phù hợp hơn  
9. Gợi ý địa điểm bán (Google Maps / Link shop)  
10. Voice search  
11. Wishlist sản phẩm  
12. Lịch sử quét  
13. Theo dõi tiến trình sức khỏe

## 4. Phương pháp tính chiều cao -- cân nặng (BMI) {#phương-pháp-tính-chiều-cao-cân-nặng-bmi}

BMI = Cân nặng (kg) / (Chiều cao (m))²  
  
Phân loại:  
- BMI \< 18.5 : Gầy  
- 18.5 -- 24.9 : Bình thường  
- 25 -- 29.9 : Thừa cân  
- ≥ 30 : Béo phì

## 5. Cấu trúc thư mục Flutter chuẩn {#cấu-trúc-thư-mục-flutter-chuẩn}

smart_health_scanner/
├── lib/
│   ├── main.dart                          # Entry point
│   ├── app.dart                           # MaterialApp config
│   │
│   ├── core/                              # Core functionality
│   │   ├── constants/
│   │   │   ├── app_constants.dart         # App-wide constants
│   │   │   ├── api_constants.dart         # API endpoints
│   │   │   └── storage_constants.dart     # Storage keys
│   │   │
│   │   ├── theme/
│   │   │   ├── app_theme.dart             # Theme configuration
│   │   │   ├── app_colors.dart            # Color palette
│   │   │   └── app_text_styles.dart       # Text styles
│   │   │
│   │   ├── utils/
│   │   │   ├── validators.dart            # Input validators
│   │   │   ├── formatters.dart            # Data formatters
│   │   │   ├── bmi_calculator.dart        # BMI calculation
│   │   │   └── date_utils.dart            # Date utilities
│   │   │
│   │   └── services/
│   │       ├── firebase_service.dart      # Firebase initialization
│   │       ├── storage_service.dart       # Local storage
│   │       └── navigation_service.dart    # Navigation helper
│   │
│   ├── data/                              # Data layer
│   │   ├── models/
│   │   │   ├── user_model.dart            # User data model
│   │   │   ├── product_model.dart         # Product data model
│   │   │   ├── health_profile_model.dart  # Health profile
│   │   │   └── scan_history_model.dart    # Scan history
│   │   │
│   │   ├── repositories/
│   │   │   ├── auth_repository.dart       # Auth operations
│   │   │   ├── user_repository.dart       # User CRUD
│   │   │   ├── product_repository.dart    # Product CRUD
│   │   │   └── scan_repository.dart       # Scan operations
│   │   │
│   │   └── datasources/
│   │       ├── firebase_datasource.dart   # Firebase operations
│   │       ├── local_datasource.dart      # Local DB operations
│   │       └── api_datasource.dart        # External API calls
│   │
│   ├── features/                          # Feature modules
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── register_screen.dart
│   │   │   │   └── forgot_password_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── auth_text_field.dart
│   │   │   │   └── auth_button.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── screens/
│   │   │   │   ├── profile_screen.dart
│   │   │   │   └── edit_profile_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── bmi_card.dart
│   │   │   │   └── health_stats_card.dart
│   │   │   └── providers/
│   │   │       └── profile_provider.dart
│   │   │
│   │   ├── scan/
│   │   │   ├── screens/
│   │   │   │   ├── scan_screen.dart
│   │   │   │   └── image_scan_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── barcode_scanner_widget.dart
│   │   │   │   └── scan_button.dart
│   │   │   └── providers/
│   │   │       └── scan_provider.dart
│   │   │
│   │   ├── product/
│   │   │   ├── screens/
│   │   │   │   └── product_detail_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── product_info_card.dart
│   │   │   │   ├── nutrition_table.dart
│   │   │   │   └── ingredient_list.dart
│   │   │   └── providers/
│   │   │       └── product_provider.dart
│   │   │
│   │   ├── ai_analysis/
│   │   │   ├── screens/
│   │   │   │   └── analysis_result_screen.dart
│   │   │   ├── widgets/
│   │   │   │   ├── health_score_widget.dart
│   │   │   │   └── warning_card.dart
│   │   │   └── providers/
│   │   │       └── ai_analysis_provider.dart
│   │   │
│   │   ├── recommendation/
│   │   │   ├── screens/
│   │   │   │   └── recommendation_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── product_recommendation_card.dart
│   │   │   └── providers/
│   │   │       └── recommendation_provider.dart
│   │   │
│   │   ├── wishlist/
│   │   │   ├── screens/
│   │   │   │   └── wishlist_screen.dart
│   │   │   ├── widgets/
│   │   │   │   └── wishlist_item.dart
│   │   │   └── providers/
│   │   │       └── wishlist_provider.dart
│   │   │
│   │   └── history/
│   │       ├── screens/
│   │       │   └── history_screen.dart
│   │       ├── widgets/
│   │       │   └── history_item.dart
│   │       └── providers/
│   │           └── history_provider.dart
│   │
│   ├── shared/                            # Shared components
│   │   ├── widgets/
│   │   │   ├── custom_button.dart
│   │   │   ├── custom_text_field.dart
│   │   │   ├── loading_widget.dart
│   │   │   ├── error_widget.dart
│   │   │   └── bottom_nav_bar.dart
│   │   │
│   │   └── dialogs/
│   │       ├── confirmation_dialog.dart
│   │       └── info_dialog.dart
│   │
│   └── routes/
│       ├── app_routes.dart                # Route names
│       └── route_generator.dart           # Route configuration
│
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
│
├── test/
│   ├── unit/
│   ├── widget/
│   └── integration/
│
├── pubspec.yaml                           # Dependencies
├── README.md                              # Project documentation
├── .gitignore
└── analysis_options.yaml                  # Lint rules

## 6. Firebase sử dụng {#firebase-sử-dụng}

\- Firebase Authentication  
- Cloud Firestore  
- Firebase Storage

## 7. Lộ trình phát triển (8 tuần) {#lộ-trình-phát-triển-8-tuần}

Tuần 1: Khởi tạo project, setup Firebase, cấu trúc thư mục

Tuần 2: Auth + hồ sơ người dùng + BMI

Tuần 3: Quét mã & hiển thị sản phẩm

Tuần 4: Phân tích thành phần

Tuần 5: AI chấm điểm sức khỏe

Tuần 6: Gợi ý sản phẩm & địa điểm bán

Tuần 7: Voice search & Image recognition

Tuần 8: Wishlist, history, tối ưu & hoàn thiện

## 8. Hướng phát triển tiếp theo {#hướng-phát-triển-tiếp-theo}

\- Theo dõi cân nặng theo thời gian  
- Gợi ý thực đơn cá nhân hóa  
- Premium AI tư vấn dinh dưỡng
