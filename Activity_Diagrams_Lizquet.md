# Activity Diagrams – Ứng dụng Lizquet (Mermaid)

---

## UC-01 – Đăng ký tài khoản

```mermaid
flowchart TD
    S([●]) --> A[Chọn chức năng Đăng ký]
    A --> B[Hệ thống hiển thị form đăng ký]
    B --> C[Người dùng nhập email và mật khẩu]
    C --> D[Nhấn nút Đăng ký]
    D --> E{Thông tin hợp lệ?}
    E -->|Không| F[Hiển thị lỗi validation]
    F --> C
    E -->|Có| G{Email đã tồn tại?}
    G -->|Có| H[Thông báo: Tài khoản đã được đăng ký]
    H --> C
    G -->|Không| I[Tạo tài khoản Firebase Auth]
    I --> J{Lưu thành công?}
    J -->|Lỗi mạng / hệ thống| K[Thông báo lỗi hệ thống]
    K --> END([◉])
    J -->|Thành công| L[Lưu thông tin người dùng vào Firestore]
    L --> M[Thông báo đăng ký thành công]
    M --> N[Tự động chuyển đến màn hình Home]
    N --> END
```

---

## UC-02 – Đăng nhập tài khoản

```mermaid
flowchart TD
    S([●]) --> A[Người dùng mở ứng dụng]
    A --> B[Hệ thống hiển thị màn hình Đăng nhập]
    B --> C[Người dùng nhập email và mật khẩu]
    C --> D[Nhấn nút Đăng nhập]
    D --> E{Thông tin hợp lệ?}
    E -->|Không| F[Hiển thị lỗi validation]
    F --> C
    E -->|Có| G[Gửi thông tin xác thực lên Firebase Auth]
    G --> H{Xác thực thành công?}
    H -->|Sai mật khẩu / không tồn tại| I[Thông báo lỗi đăng nhập]
    I --> C
    H -->|Lỗi mạng| J[Thông báo mất kết nối]
    J --> END([◉])
    H -->|Thành công| K[Firebase trả về token xác thực]
    K --> L[Lưu phiên đăng nhập persistent]
    L --> M[Chuyển đến màn hình Home]
    M --> END
```

---

## UC-03 – Tạo bộ thẻ

```mermaid
flowchart TD
    S([●]) --> A[Người dùng chọn Tạo → Bộ thẻ]
    A --> B[Hệ thống hiển thị form tạo bộ thẻ]
    B --> C[Nhập tiêu đề và mô tả bộ thẻ]
    C --> D[Thêm các thẻ từ - mặt trước / mặt sau]
    D --> E{Tiêu đề bỏ trống?}
    E -->|Có| F[Yêu cầu nhập tiêu đề]
    F --> C
    E -->|Không| G{Bộ thẻ có thẻ từ không?}
    G -->|Không| H[Cảnh báo: Bộ thẻ đang trống]
    H --> D
    G -->|Có| I[Người dùng nhấn Lưu]
    I --> J[Hệ thống lưu bộ thẻ vào Firestore]
    J --> K{Lưu thành công?}
    K -->|Lỗi mạng| L[Thông báo lỗi lưu dữ liệu]
    L --> END([◉])
    K -->|Thành công| M[Thông báo tạo bộ thẻ thành công]
    M --> N[Chuyển đến màn hình chi tiết bộ thẻ]
    N --> END
```

---

## UC-04 – Chỉnh sửa bộ thẻ

```mermaid
flowchart TD
    S([●]) --> A[Người dùng chọn Chỉnh sửa từ màn hình chi tiết]
    A --> B[Hệ thống tải thông tin bộ thẻ hiện tại vào form]
    B --> C{Người dùng có quyền chỉnh sửa?}
    C -->|Không| D[Thông báo không có quyền]
    D --> END([◉])
    C -->|Có| E[Hiển thị form với dữ liệu hiện tại]
    E --> F[Người dùng thay đổi tiêu đề / mô tả / thẻ từ]
    F --> G{Hủy chỉnh sửa?}
    G -->|Có| H[Quay về màn hình chi tiết - không thay đổi]
    H --> END
    G -->|Không| I[Nhấn Lưu]
    I --> J{Tiêu đề hợp lệ?}
    J -->|Không| K[Hiển thị lỗi validation]
    K --> F
    J -->|Có| L[Cập nhật dữ liệu trong Firestore]
    L --> M{Cập nhật thành công?}
    M -->|Lỗi mạng| N[Thông báo lỗi cập nhật]
    N --> END
    M -->|Thành công| O[Thông báo cập nhật thành công]
    O --> P[Quay về màn hình chi tiết bộ thẻ]
    P --> END
```

---

## UC-05 – Xem chi tiết bộ thẻ

```mermaid
flowchart TD
    S([●]) --> A[Người dùng nhấn vào bộ thẻ]
    A --> B[Hệ thống tải dữ liệu bộ thẻ từ Firestore]
    B --> C{Tải thành công?}
    C -->|Lỗi / Bộ thẻ không tồn tại| D[Thông báo lỗi]
    D --> END([◉])
    C -->|Thành công| E{Bộ thẻ có thẻ từ không?}
    E -->|Không| F[Hiển thị trạng thái rỗng - gợi ý thêm thẻ]
    F --> G[Người dùng chọn thêm thẻ từ]
    G --> END
    E -->|Có| H[Hiển thị tiêu đề, số thẻ và danh sách thẻ từ]
    H --> I[Hiển thị các nút chế độ học]
    I --> J{Người dùng chọn hành động}
    J -->|Flashcard| K[Vào UC-06 Học Flashcard]
    J -->|Learn| L[Vào UC-07 Học Learn]
    J -->|Test| M[Vào UC-08 Kiểm tra]
    J -->|Match| N[Vào UC-09 Ghép từ]
    J -->|Flappy| O[Vào UC-10 Flappy Bird]
    J -->|Chỉnh sửa| P[Vào UC-04 Chỉnh sửa]
    K & L & M & N & O & P --> END
```

---

## UC-06 – Học Flashcard

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống tải danh sách thẻ từ]
    A --> B{Tải thành công?}
    B -->|Lỗi| C[Thông báo lỗi tải dữ liệu]
    C --> END([◉])
    B -->|Thành công| D[Xáo trộn thứ tự thẻ ngẫu nhiên]
    D --> E[Hiển thị thẻ đầu tiên - mặt trước]
    E --> F[Người dùng nhấn thẻ]
    F --> G[Lật thẻ - hiển thị mặt sau]
    G --> H[Phát hiệu ứng âm thanh nếu bật]
    H --> I{Còn thẻ tiếp theo?}
    I -->|Có| J{Vuốt / nhấn nút chuyển}
    J -->|Tiếp theo| E
    J -->|Thoát giữa chừng| K[Kết thúc phiên - không lưu tiến độ]
    K --> END
    I -->|Không - hoàn thành| L[Hiển thị màn hình hoàn thành]
    L --> M[Ghi nhận ngày học - cập nhật Streak]
    M --> END
```

---

## UC-07 – Học theo chế độ Learn

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống tải thẻ từ và tạo câu hỏi]
    A --> B{Tải thành công?}
    B -->|Lỗi| C[Thông báo lỗi]
    C --> END([◉])
    B -->|Thành công| D[Hiển thị câu hỏi và các lựa chọn]
    D --> E{Người dùng thoát giữa chừng?}
    E -->|Có| F[Lưu tiến độ đến câu hiện tại]
    F --> END
    E -->|Không| G[Người dùng chọn đáp án]
    G --> H{Đáp án đúng?}
    H -->|Đúng| I[Hiển thị phản hồi đúng - màu xanh + âm thanh]
    H -->|Sai| J[Hiển thị phản hồi sai - màu đỏ + âm thanh]
    J --> K[Đưa thẻ vào vòng ôn tập]
    I & K --> L{Còn câu hỏi tiếp theo?}
    L -->|Có| D
    L -->|Không| M[Hiển thị kết quả phiên học]
    M --> N[Lưu tiến độ vào Firestore]
    N --> O[Ghi nhận ngày học - cập nhật Streak]
    O --> END
```

---

## UC-08 – Làm bài kiểm tra (Test)

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống tạo đề kiểm tra từ bộ thẻ]
    A --> B{Tải thành công?}
    B -->|Lỗi| C[Thông báo lỗi tải câu hỏi]
    C --> END([◉])
    B -->|Thành công| D[Xáo trộn câu hỏi và đáp án ngẫu nhiên]
    D --> E[Hiển thị câu hỏi đầu tiên]
    E --> F{Người dùng thoát giữa chừng?}
    F -->|Có| G[Hủy bài thi - không lưu điểm]
    G --> END
    F -->|Không| H[Người dùng chọn đáp án]
    H --> I{Còn câu tiếp theo?}
    I -->|Có| E
    I -->|Không| J[Người dùng nộp bài]
    J --> K[Hệ thống chấm điểm tất cả câu]
    K --> L[Hiển thị kết quả chi tiết đúng/sai từng câu]
    L --> M[Hiển thị tổng điểm và tỉ lệ đúng]
    M --> N[Ghi nhận ngày học - cập nhật Streak]
    N --> END([◉])
```

---

## UC-09 – Chơi trò chơi ghép từ (Match)

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống tải thẻ từ]
    A --> B{Tải thành công?}
    B -->|Lỗi| C[Thông báo lỗi tải dữ liệu]
    C --> END([◉])
    B -->|Thành công| D[Xáo trộn và hiển thị các ô từ và nghĩa]
    D --> E[Bắt đầu đếm thời gian]
    E --> F[Người dùng chọn một ô từ]
    F --> G[Người dùng chọn ô nghĩa tương ứng]
    G --> H{Ghép đúng?}
    H -->|Sai| I[Hiển thị hiệu ứng sai - ô rung đỏ]
    I --> F
    H -->|Đúng| J[Hiển thị hiệu ứng đúng - ô biến mất]
    J --> K{Còn cặp từ chưa ghép?}
    K -->|Có| F
    K -->|Không| L[Dừng đếm thời gian]
    L --> M[Hiển thị thời gian hoàn thành]
    M --> N[Ghi nhận ngày học - cập nhật Streak]
    N --> END([◉])
```

---

## UC-10 – Chơi Flappy Bird học từ vựng

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống tải thẻ từ từ bộ thẻ]
    A --> B{Tải thành công?}
    B -->|Lỗi| C[Thông báo lỗi]
    C --> END([◉])
    B -->|Thành công| D[Khởi động Flame Game Engine]
    D --> E{Khởi động thành công?}
    E -->|Lỗi Engine| F[Thông báo lỗi khởi động game]
    F --> END
    E -->|Thành công| G[Con chim xuất hiện - bắt đầu trò chơi]
    G --> H[Người dùng chạm màn hình điều khiển chim bay]
    H --> I{Gặp chướng ngại vật?}
    I -->|Không| H
    I -->|Có| J[Hiển thị câu hỏi từ vựng]
    J --> K[Người dùng chọn đáp án]
    K --> L{Đáp án đúng?}
    L -->|Sai| M[Game Over - Hiển thị màn hình thua]
    M --> N{Chơi lại?}
    N -->|Có| G
    N -->|Không| END([◉])
    L -->|Đúng| O[Chim vượt qua chướng ngại vật]
    O --> P{Hoàn thành tất cả thẻ?}
    P -->|Chưa| H
    P -->|Rồi| Q[Hiển thị màn hình chiến thắng]
    Q --> R[Ghi nhận ngày học - cập nhật Streak]
    R --> END
```

---

## UC-11 – Quản lý thư mục (Folder)

```mermaid
flowchart TD
    S([●]) --> A{Người dùng chọn hành động}
    A -->|Tạo mới| B[Chọn Tạo → Thư mục]
    B --> C[Hệ thống hiển thị form nhập tên thư mục]
    C --> D[Người dùng nhập tên và chọn bộ thẻ]
    D --> E{Tên trống?}
    E -->|Có| F[Yêu cầu nhập tên]
    F --> D
    E -->|Không| G[Lưu thư mục vào Firestore]
    G --> H{Lưu thành công?}
    H -->|Lỗi mạng| I[Thông báo lỗi lưu dữ liệu]
    I --> END([◉])
    H -->|Thành công| J[Thư mục hiển thị trong tab Thư viện]
    J --> END
    A -->|Xem chi tiết| K[Hiển thị danh sách bộ thẻ trong thư mục]
    K --> END
    A -->|Xóa thư mục| L[Xác nhận xóa]
    L --> M[Xóa thư mục - giữ nguyên bộ thẻ bên trong]
    M --> N[Cập nhật Firestore]
    N --> END
```

---

## UC-12 – Quản lý nhóm học (Group)

```mermaid
flowchart TD
    S([●]) --> A{Người dùng chọn hành động}
    A -->|Tạo nhóm| B[Chọn Tạo → Nhóm]
    B --> C[Hệ thống hiển thị form nhập thông tin nhóm]
    C --> D[Người dùng nhập tên và mô tả nhóm]
    D --> E{Tên trống?}
    E -->|Có| F[Yêu cầu nhập tên]
    F --> D
    E -->|Không| G[Tạo nhóm trong Firestore với người tạo làm admin]
    G --> H{Tạo thành công?}
    H -->|Lỗi mạng| I[Thông báo lỗi]
    I --> END([◉])
    H -->|Thành công| J[Nhóm hiển thị trong tab Thư viện]
    J --> END
    A -->|Quản lý nhóm - Admin| K[Xem danh sách thành viên]
    K --> L{Hành động admin}
    L -->|Thêm bộ thẻ| M[Chọn bộ thẻ và thêm vào nhóm]
    L -->|Mời thành viên| N[Nhập thông tin và gửi lời mời]
    L -->|Xóa thành viên| O[Xác nhận và xóa thành viên]
    M & N & O --> P[Cập nhật Firestore]
    P --> END
    A -->|Xem nhóm - Thành viên| Q[Xem bộ thẻ trong nhóm]
    Q --> END
```

---

## UC-13 – Khám phá từ vựng theo cấp độ CEFR

```mermaid
flowchart TD
    S([●]) --> A[Hệ thống hiển thị danh sách cấp độ CEFR]
    A --> B[A1 / A2 / B1 / B2 / C1 / C2]
    B --> C[Người dùng chọn một cấp độ]
    C --> D[Hệ thống tải danh sách bộ từ vựng theo cấp độ]
    D --> E{Tải thành công?}
    E -->|Lỗi| F[Thông báo lỗi tải dữ liệu]
    F --> END([◉])
    E -->|Không có dữ liệu| G[Thông báo: Chưa có nội dung cho cấp độ này]
    G --> END
    E -->|Thành công| H[Hiển thị danh sách bộ từ vựng]
    H --> I[Người dùng chọn một bộ từ vựng]
    I --> J[Hiển thị chi tiết bộ từ vựng]
    J --> K{Người dùng chọn hành động}
    K -->|Học ngay| L[Chọn chế độ học - UC-06 đến UC-10]
    K -->|Lưu về thư viện| M[Sao chép bộ thẻ vào thư viện cá nhân]
    M --> N[Lưu vào Firestore]
    N --> O[Thông báo lưu thành công]
    L & O --> END
```

---

## UC-14 – Xem hồ sơ cá nhân & chuỗi học

```mermaid
flowchart TD
    S([●]) --> A[Người dùng nhấn tab Cá nhân]
    A --> B[Hệ thống tải thông tin từ Firebase Auth]
    B --> C[Hệ thống tải thống kê bộ thẻ từ Firestore]
    C --> D[Hệ thống lắng nghe stream dữ liệu Streak từ Firestore]
    D --> E{Tải thành công?}
    E -->|Lỗi| F[Hiển thị trạng thái lỗi]
    F --> END([◉])
    E -->|Thành công| G[Hiển thị avatar và tên người dùng]
    G --> H[Hiển thị thống kê: số bộ thẻ / số thẻ từ / streak ngày]
    H --> I{Có chuỗi học không?}
    I -->|Không - streak = 0| J[Hiển thị: Chưa có chuỗi - gợi ý học ngay]
    I -->|Có| K[Hiển thị thẻ thành tựu streak và kỷ lục]
    J & K --> L[Hiển thị lịch học 7 ngày trong tuần]
    L --> M{Người dùng chọn hành động}
    M -->|Cài đặt| N[Chuyển đến UC-15 Cài đặt]
    M -->|Đăng xuất| O[Xác nhận đăng xuất]
    O --> P[Xóa phiên đăng nhập Firebase Auth]
    P --> Q[Chuyển về màn hình Đăng nhập]
    N & Q --> END([◉])
```

---

## UC-15 – Cài đặt tài khoản & ứng dụng

```mermaid
flowchart TD
    S([●]) --> A[Người dùng chọn Cài đặt từ hồ sơ]
    A --> B[Hệ thống tải thông tin tài khoản và cài đặt hiện tại]
    B --> C[Hiển thị màn hình Cài đặt]
    C --> D{Người dùng chọn hành động}

    D -->|Nhấn vào Tên| E[Hiển thị bottom sheet chỉnh sửa tên]
    E --> F[Người dùng nhập tên mới]
    F --> G{Tên mới hợp lệ?}
    G -->|Trống| H[Thông báo lỗi - không lưu]
    H --> C
    G -->|Hợp lệ| I[Cập nhật Firebase Auth displayName]
    I --> J[Cập nhật Firestore users collection]
    J --> K[Tên mới hiển thị ngay lập tức toàn app]
    K --> C

    D -->|Bật/Tắt Chế độ tối| L[Cập nhật ThemeMode trong AppSettingsNotifier]
    L --> M[Lưu trạng thái vào SharedPreferences]
    M --> N[Giao diện toàn app thay đổi ngay lập tức]
    N --> C

    D -->|Bật/Tắt Âm thanh| O[Cập nhật soundEnabled trong AppSettingsNotifier]
    O --> P[Lưu trạng thái vào SharedPreferences]
    P --> Q[AudioService cập nhật enabled flag]
    Q --> C

    D -->|Quay lại| R[Quay về màn hình Hồ sơ]
    R --> END([◉])
```
