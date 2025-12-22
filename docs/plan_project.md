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

lib/  
├── main.dart  
├── app.dart  
├── core/  
│ ├── constants/  
│ ├── theme/  
│ ├── utils/  
│ └── services/  
├── data/  
│ ├── models/  
│ ├── repositories/  
│ └── datasources/  
├── features/  
│ ├── auth/  
│ ├── profile/  
│ ├── scan/  
│ ├── product/  
│ ├── ai_analysis/  
│ ├── recommendation/  
│ ├── wishlist/  
│ └── history/  
├── shared/  
│ ├── widgets/  
│ └── dialogs/  
└── routes/  
└── app_routes.dart

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
