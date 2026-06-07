# BÁO CÁO PHÂN TÍCH HỆ THỐNG LIZQUET (LEARNING APP)

## 2.4.3 Mô hình lớp và đối tượng
Biểu đồ lớp mô tả cấu trúc hướng đối tượng của hệ thống Lizquet, bao gồm các lớp thực thể (Model) đại diện cho dữ liệu học tập và các lớp kho dữ liệu (Repository) xử lý logic nghiệp vụ.

- **Nhóm Model (Thực thể dữ liệu):** Các lớp như `UserModel`, `DeckModel` (Bộ thẻ), `CardModel` (Thẻ ghi nhớ), `FolderModel` (Thư mục) và `GroupModel` (Nhóm) được thiết kế tương ứng với cấu trúc tài liệu trong Cloud Firestore. Đặc biệt, `CardModel` chứa các thuộc tính về thuật ngữ (term) và định nghĩa (definition), trong khi `ProgressModel` theo dõi lịch sử học tập và tỷ lệ ghi nhớ của người dùng.
- **Nhóm Repository/Service (Xử lý nghiệp vụ):** Các lớp như `AuthRepository`, `DeckRepository`, `FolderRepository` đóng vai trò trung gian, thực hiện các thao tác CRUD (Thêm, Sửa, Xóa) dữ liệu trên Firebase và cung cấp dữ liệu sạch cho tầng giao diện thông qua Riverpod Providers.

## 2.4.4 Tổ chức mã nguồn và Quản lý trạng thái
Mã nguồn ứng dụng được tổ chức trong thư mục `lib`, tuân thủ kiến trúc phân tầng (Layered Architecture) kết hợp với cấu trúc module hóa theo tính năng (**Feature-based structure**) để tối ưu khả năng mở rộng:

- **Presentation Layer (Giao diện):** Nằm trong gói `features`, chia nhỏ theo từng module chức năng như `auth`, `deck`, `study`, `library`... Mỗi module chứa các màn hình (screens) và các thành phần giao diện nhỏ (widgets) riêng biệt.
- **State Management Layer (Quản lý trạng thái):** Sử dụng thư viện **Riverpod** với các `Notifier` và `Provider` (như `authProvider`, `appRouterProvider`). Đây là tầng điều phối dữ liệu, đảm bảo giao diện luôn phản ánh đúng trạng thái mới nhất của dữ liệu học tập.
- **Data Layer (Dữ liệu):** Bao gồm các `models` dùng chung tại `lib/shared/models` và các `repositories` tại mỗi feature để giao tiếp với Firebase API.
- **Core & Shared:** Chứa các cấu hình hệ thống như Router (GoRouter), Theme (AppTheme), và các tiện ích (utils) dùng chung cho toàn bộ ứng dụng.

## 2.4.5 Mô hình triển khai (Deployment Model)
Hệ thống được triển khai theo mô hình kiến trúc **Serverless**, tận dụng hạ tầng điện toán đám mây của Google Firebase để đảm bảo tốc độ phản hồi nhanh và khả năng đồng bộ hóa tức thì.

**Các thành phần chính trong mô hình triển khai:**

1. **Thiết bị người dùng (Client Node):** Các thiết bị di động chạy hệ điều hành Android hoặc iOS. Ứng dụng Flutter được đóng gói thành tệp cài đặt và tương tác với hệ thống qua môi trường thực thi của Flutter SDK.
2. **Hạ tầng Backend (Cloud Node - Firebase):**
    - **Firebase Authentication:** Quản lý danh tính người dùng và bảo mật phiên đăng nhập.
    - **Cloud Firestore:** Cơ sở dữ liệu NoSQL lưu trữ cấu trúc bộ thẻ, thư mục, nhóm và dữ liệu học tập theo thời gian thực.
    - **Firebase Storage:** Lưu trữ hình ảnh minh họa cho các thẻ ghi nhớ và ảnh đại diện người dùng.

**Giao thức kết nối:**
- **HTTPS:** Sử dụng cho các truy vấn dữ liệu và xác thực người dùng qua RESTful API.
- **gRPC/Websocket:** Được SDK Firestore sử dụng để duy trì kết nối thời gian thực, giúp người dùng cập nhật nội dung học tập ngay lập tức khi có sự thay đổi trên các thiết bị khác nhau.
