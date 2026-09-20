# Đặc tả Use Case – Ứng dụng Lizquet

---

## UC-01 – Đăng ký tài khoản

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-01 – Đăng ký tài khoản |
| **Mô tả** | Cho phép người dùng tạo mới một tài khoản trên hệ thống bằng cách cung cấp email và mật khẩu. Sau khi đăng ký thành công, người dùng có thể đăng nhập và sử dụng các chức năng của ứng dụng. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Authentication / Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn chức năng Đăng ký trên màn hình đăng nhập. |
| **Tiền điều kiện** | Người dùng chưa có tài khoản trên hệ thống. Hệ thống đang hoạt động bình thường. |
| **Hậu điều kiện** | Tài khoản mới được tạo và lưu vào Firebase. Người dùng có thể đăng nhập bằng tài khoản vừa đăng ký. |
| **Luồng thông thường** | 1. Người dùng chọn chức năng Đăng ký. 2. Hệ thống hiển thị form đăng ký. 3. Người dùng nhập email và mật khẩu. 4. Người dùng nhấn nút Đăng ký. 5. Hệ thống kiểm tra tính hợp lệ của thông tin. 6. Hệ thống tạo tài khoản và lưu vào Firebase Auth + Firestore. 7. Hệ thống tự động chuyển sang màn hình chính. |
| **Luồng thay thế** | Thông tin nhập không hợp lệ → Hệ thống thông báo lỗi và yêu cầu nhập lại. Email đã tồn tại → Hệ thống thông báo tài khoản đã được đăng ký. |
| **Các ngoại lệ** | Lỗi hệ thống khi lưu dữ liệu. Mất kết nối mạng trong quá trình đăng ký. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Email phải đúng định dạng và là duy nhất. Mật khẩu phải đáp ứng yêu cầu bảo mật (tối thiểu 6 ký tự). |
| **Các giả thuyết** | Người dùng cung cấp thông tin chính xác và hợp lệ. Hệ thống có cơ chế kiểm tra và lưu trữ tài khoản an toàn qua Firebase. |

---

## UC-02 – Đăng nhập tài khoản

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-02 – Đăng nhập tài khoản |
| **Mô tả** | Cho phép người dùng đã có tài khoản xác thực danh tính và truy cập vào hệ thống bằng email và mật khẩu đã đăng ký. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Authentication |
| **Sự kiện kích hoạt** | Người dùng mở ứng dụng và chọn Đăng nhập. |
| **Tiền điều kiện** | Người dùng đã có tài khoản trên hệ thống. Hệ thống đang hoạt động bình thường. |
| **Hậu điều kiện** | Người dùng được xác thực thành công và chuyển đến màn hình chính (Home). |
| **Luồng thông thường** | 1. Người dùng nhập email và mật khẩu. 2. Người dùng nhấn nút Đăng nhập. 3. Hệ thống gửi thông tin xác thực lên Firebase Auth. 4. Firebase trả về token xác thực. 5. Hệ thống chuyển người dùng đến màn hình Home. |
| **Luồng thay thế** | Sai email hoặc mật khẩu → Hệ thống thông báo lỗi xác thực. Tài khoản không tồn tại → Hệ thống thông báo và gợi ý đăng ký. |
| **Các ngoại lệ** | Mất kết nối mạng trong quá trình xác thực. Lỗi từ phía Firebase Authentication. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Người dùng chưa đăng nhập không thể truy cập các chức năng của ứng dụng. Hệ thống duy trì phiên đăng nhập tự động (persistent auth). |
| **Các giả thuyết** | Người dùng nhớ thông tin tài khoản. Firebase Authentication hoạt động bình thường. |

---

## UC-03 – Tạo bộ thẻ (Deck)

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-03 – Tạo bộ thẻ |
| **Mô tả** | Cho phép người dùng tạo một bộ thẻ học mới bằng cách nhập tiêu đề, mô tả và thêm các thẻ từ (flashcard) vào bộ thẻ. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn Tạo → Bộ thẻ từ bottom sheet hoặc nút tạo trên màn hình chính. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Hệ thống đang hoạt động bình thường. |
| **Hậu điều kiện** | Bộ thẻ mới được lưu vào Firestore và hiển thị trong danh sách thư viện của người dùng. |
| **Luồng thông thường** | 1. Người dùng chọn tạo bộ thẻ mới. 2. Hệ thống hiển thị form tạo bộ thẻ. 3. Người dùng nhập tiêu đề và mô tả bộ thẻ. 4. Người dùng thêm các thẻ từ (mặt trước / mặt sau). 5. Người dùng lưu bộ thẻ. 6. Hệ thống lưu dữ liệu vào Firestore. 7. Hệ thống thông báo tạo thành công và chuyển về chi tiết bộ thẻ. |
| **Luồng thay thế** | Tiêu đề bỏ trống → Hệ thống yêu cầu nhập tiêu đề trước khi lưu. Không có thẻ nào → Hệ thống cảnh báo bộ thẻ trống. |
| **Các ngoại lệ** | Mất kết nối khi lưu → Dữ liệu chưa được lưu. Lỗi Firestore khi ghi dữ liệu. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Mỗi bộ thẻ phải có tiêu đề. Thẻ từ cần có ít nhất nội dung mặt trước. |
| **Các giả thuyết** | Người dùng có kết nối internet ổn định khi tạo bộ thẻ. |

---

## UC-04 – Chỉnh sửa bộ thẻ

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-04 – Chỉnh sửa bộ thẻ |
| **Mô tả** | Cho phép người dùng cập nhật tiêu đề, mô tả và nội dung các thẻ từ trong một bộ thẻ đã tạo. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn Chỉnh sửa từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ đã tồn tại và thuộc sở hữu của người dùng. |
| **Hậu điều kiện** | Bộ thẻ được cập nhật thành công trong Firestore. |
| **Luồng thông thường** | 1. Người dùng chọn chỉnh sửa bộ thẻ. 2. Hệ thống tải thông tin bộ thẻ hiện tại vào form. 3. Người dùng thay đổi tiêu đề, mô tả hoặc thẻ từ. 4. Người dùng lưu thay đổi. 5. Hệ thống cập nhật dữ liệu trong Firestore. 6. Hệ thống thông báo cập nhật thành công. |
| **Luồng thay thế** | Người dùng hủy chỉnh sửa → Quay về màn hình chi tiết, dữ liệu không thay đổi. |
| **Các ngoại lệ** | Mất kết nối khi lưu → Thay đổi chưa được cập nhật. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Chỉ chủ sở hữu bộ thẻ mới có quyền chỉnh sửa. |
| **Các giả thuyết** | Người dùng muốn cập nhật nội dung học của mình. |

---

## UC-05 – Xem chi tiết bộ thẻ

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-05 – Xem chi tiết bộ thẻ |
| **Mô tả** | Cho phép người dùng xem toàn bộ thẻ từ trong một bộ thẻ và lựa chọn chế độ học phù hợp. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng nhấn vào một bộ thẻ từ danh sách thư viện hoặc trang chủ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ tồn tại trong hệ thống. |
| **Hậu điều kiện** | Người dùng xem được danh sách thẻ từ và có thể chọn chế độ học. |
| **Luồng thông thường** | 1. Người dùng nhấn vào bộ thẻ. 2. Hệ thống tải danh sách thẻ từ từ Firestore. 3. Hệ thống hiển thị tiêu đề, số lượng thẻ và danh sách thẻ từ. 4. Hệ thống hiển thị các nút chọn chế độ học (Flashcard, Learn, Test, Match, Flappy). 5. Người dùng chọn chế độ học hoặc duyệt danh sách thẻ. |
| **Luồng thay thế** | Bộ thẻ trống (chưa có thẻ nào) → Hệ thống hiển thị trạng thái rỗng và gợi ý thêm thẻ. |
| **Các ngoại lệ** | Bộ thẻ bị xóa hoặc không tồn tại → Hệ thống thông báo lỗi. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Bộ thẻ phải có ít nhất 1 thẻ từ mới có thể bắt đầu học. |
| **Các giả thuyết** | Người dùng có kết nối internet để tải dữ liệu từ Firestore. |

---

## UC-06 – Học Flashcard

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-06 – Học Flashcard |
| **Mô tả** | Cho phép người dùng học từ vựng bằng cách lật từng thẻ, xem mặt trước (từ) và mặt sau (nghĩa/định nghĩa) theo kiểu flashcard truyền thống. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn chế độ Flashcard từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ có ít nhất 1 thẻ từ. |
| **Hậu điều kiện** | Người dùng hoàn thành vòng học flashcard. Chuỗi học (streak) được cập nhật nếu đây là lần học đầu tiên trong ngày. |
| **Luồng thông thường** | 1. Hệ thống tải danh sách thẻ từ và hiển thị thẻ đầu tiên (mặt trước). 2. Người dùng nhấn vào thẻ để lật xem mặt sau. 3. Người dùng vuốt sang trái/phải hoặc nhấn nút để chuyển thẻ tiếp theo. 4. Lặp lại đến khi hết bộ thẻ. 5. Hệ thống hiển thị màn hình hoàn thành. |
| **Luồng thay thế** | Người dùng thoát giữa chừng → Tiến độ không được lưu, có thể bắt đầu lại. |
| **Các ngoại lệ** | Lỗi tải dữ liệu thẻ từ Firestore. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Thứ tự thẻ có thể được xáo trộn ngẫu nhiên. Hiệu ứng âm thanh phát khi lật thẻ (nếu bật). |
| **Các giả thuyết** | Người dùng muốn ôn luyện từ vựng theo cách trực quan. |

---

## UC-07 – Học theo chế độ Learn

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-07 – Học theo chế độ Learn |
| **Mô tả** | Cho phép người dùng học từ vựng qua các câu hỏi tương tác (trắc nghiệm, điền từ) với hệ thống theo dõi tiến độ và phản hồi tức thì đúng/sai. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn chế độ Learn từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ có ít nhất 1 thẻ từ. |
| **Hậu điều kiện** | Tiến độ học được lưu vào Firestore. Chuỗi học (streak) được ghi nhận nếu là lần học đầu tiên trong ngày. |
| **Luồng thông thường** | 1. Hệ thống tải danh sách thẻ từ và tạo câu hỏi. 2. Hệ thống hiển thị câu hỏi và các lựa chọn. 3. Người dùng chọn đáp án. 4. Hệ thống phản hồi đúng/sai với âm thanh và màu sắc. 5. Hệ thống chuyển sang câu tiếp theo. 6. Khi hoàn thành, hệ thống hiển thị kết quả và lưu tiến độ. |
| **Luồng thay thế** | Trả lời sai → Thẻ được đưa vào vòng ôn tập. Người dùng thoát giữa chừng → Tiến độ lưu lại đến câu cuối cùng đã hoàn thành. |
| **Các ngoại lệ** | Lỗi lưu tiến độ vào Firestore. Mất kết nối mạng. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Hệ thống ưu tiên ôn lại các thẻ người dùng trả lời sai. Chuỗi học chỉ tính một lần mỗi ngày. |
| **Các giả thuyết** | Người dùng muốn học chủ động với phản hồi tức thì. |

---

## UC-08 – Làm bài kiểm tra (Test)

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-08 – Làm bài kiểm tra |
| **Mô tả** | Cho phép người dùng kiểm tra kiến thức bằng một bài thi gồm nhiều câu hỏi từ bộ thẻ, sau đó xem điểm số và kết quả chi tiết. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn chế độ Test từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ có ít nhất 2 thẻ từ. |
| **Hậu điều kiện** | Kết quả bài kiểm tra hiển thị cho người dùng. Chuỗi học được cập nhật. |
| **Luồng thông thường** | 1. Hệ thống tạo đề kiểm tra từ các thẻ trong bộ thẻ. 2. Hệ thống hiển thị từng câu hỏi. 3. Người dùng trả lời tất cả câu hỏi. 4. Người dùng nộp bài. 5. Hệ thống chấm điểm và hiển thị kết quả (đúng/sai từng câu, tổng điểm). |
| **Luồng thay thế** | Người dùng thoát giữa chừng → Bài thi hủy, điểm không được lưu. |
| **Các ngoại lệ** | Lỗi tải câu hỏi từ Firestore. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Câu hỏi được xáo trộn ngẫu nhiên mỗi lần thi. Đáp án nhiễu lấy ngẫu nhiên từ các thẻ khác trong bộ thẻ. |
| **Các giả thuyết** | Người dùng muốn đánh giá mức độ ghi nhớ của mình. |

---

## UC-09 – Chơi trò chơi ghép từ (Match)

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-09 – Chơi trò chơi ghép từ |
| **Mô tả** | Cho phép người dùng học từ vựng qua trò chơi ghép đôi (từ – nghĩa) bằng cách kéo thả hoặc chạm, tính thời gian hoàn thành. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn chế độ Match từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ có ít nhất 2 thẻ từ. |
| **Hậu điều kiện** | Trò chơi hoàn thành, thời gian được ghi nhận. Chuỗi học được cập nhật. |
| **Luồng thông thường** | 1. Hệ thống hiển thị các ô từ và nghĩa xáo trộn ngẫu nhiên. 2. Bắt đầu đếm thời gian. 3. Người dùng chọn một từ và ghép với nghĩa tương ứng. 4. Hệ thống xác nhận đúng/sai và phát hiệu ứng. 5. Lặp lại đến khi tất cả được ghép đúng. 6. Hệ thống hiển thị thời gian hoàn thành. |
| **Luồng thay thế** | Ghép sai → Hệ thống hiển thị hiệu ứng sai và yêu cầu thử lại. |
| **Các ngoại lệ** | Lỗi tải dữ liệu thẻ từ. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Tối đa 6 cặp từ hiển thị mỗi vòng. Thời gian càng ngắn càng tốt. |
| **Các giả thuyết** | Người dùng muốn học từ vựng qua hình thức vui, có tính cạnh tranh. |

---

## UC-10 – Chơi Flappy Bird học từ vựng

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-10 – Chơi Flappy Bird học từ vựng |
| **Mô tả** | Cho phép người dùng kết hợp học từ vựng và trò chơi Flappy Bird: trả lời đúng câu hỏi để con chim vượt qua chướng ngại vật. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore, Flame Game Engine |
| **Sự kiện kích hoạt** | Người dùng chọn chế độ Flappy từ màn hình chi tiết bộ thẻ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Bộ thẻ có ít nhất 1 thẻ từ. |
| **Hậu điều kiện** | Trò chơi kết thúc (thắng hoặc thua). Chuỗi học được cập nhật. |
| **Luồng thông thường** | 1. Hệ thống tải thẻ từ và khởi động game. 2. Con chim xuất hiện, người dùng điều khiển bằng cách chạm màn hình. 3. Khi gặp chướng ngại vật, câu hỏi từ vựng xuất hiện. 4. Người dùng chọn đáp án đúng để vượt qua. 5. Trả lời sai → game over. 6. Hoàn thành tất cả thẻ → chiến thắng. |
| **Luồng thay thế** | Trả lời sai → Hiển thị màn hình Game Over, có thể chơi lại. |
| **Các ngoại lệ** | Lỗi khởi động Flame Engine. Thiết bị có hiệu năng thấp gây lag. |
| **Độ ưu tiên** | Thấp |
| **Các quy tắc nghiệp vụ** | Mỗi chướng ngại vật tương ứng với một thẻ từ trong bộ thẻ. Trả lời sai kết thúc game ngay lập tức. |
| **Các giả thuyết** | Thiết bị của người dùng hỗ trợ đồ họa game 2D mượt mà. |

---

## UC-11 – Quản lý thư mục (Folder)

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-11 – Quản lý thư mục |
| **Mô tả** | Cho phép người dùng tạo thư mục để tổ chức và nhóm các bộ thẻ liên quan lại với nhau, giúp quản lý nội dung học dễ dàng hơn. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn Tạo → Thư mục từ bottom sheet hoặc thư viện. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. |
| **Hậu điều kiện** | Thư mục được tạo/cập nhật và hiển thị trong thư viện. Các bộ thẻ được gán vào thư mục tương ứng. |
| **Luồng thông thường** | 1. Người dùng chọn tạo thư mục mới. 2. Hệ thống hiển thị form nhập tên thư mục. 3. Người dùng nhập tên và chọn bộ thẻ muốn thêm vào. 4. Người dùng lưu thư mục. 5. Hệ thống tạo thư mục trong Firestore và liên kết các bộ thẻ. 6. Thư mục hiển thị trong tab Thư viện. |
| **Luồng thay thế** | Tên thư mục trống → Hệ thống yêu cầu nhập tên. Xóa thư mục → Chỉ xóa thư mục, không xóa bộ thẻ bên trong. |
| **Các ngoại lệ** | Mất kết nối khi lưu dữ liệu. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Mỗi thư mục phải có tên. Một bộ thẻ có thể thuộc nhiều thư mục. |
| **Các giả thuyết** | Người dùng có nhiều bộ thẻ và cần tổ chức theo chủ đề. |

---

## UC-12 – Quản lý nhóm học (Group)

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-12 – Quản lý nhóm học |
| **Mô tả** | Cho phép người dùng tạo nhóm học tập để chia sẻ bộ thẻ với các thành viên trong nhóm, hỗ trợ học tập cộng đồng. |
| **Tác nhân chính** | Người dùng (học viên / quản trị nhóm) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng chọn Tạo → Nhóm từ bottom sheet hoặc thư viện. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. |
| **Hậu điều kiện** | Nhóm được tạo và hiển thị trong thư viện. Người tạo trở thành quản trị viên nhóm. |
| **Luồng thông thường** | 1. Người dùng chọn tạo nhóm mới. 2. Hệ thống hiển thị form nhập thông tin nhóm (tên, mô tả). 3. Người dùng nhập thông tin và lưu. 4. Hệ thống tạo nhóm trong Firestore với người tạo làm admin. 5. Nhóm hiển thị trong tab Thư viện. 6. Người dùng có thể thêm bộ thẻ và mời thành viên. |
| **Luồng thay thế** | Tên nhóm trống → Hệ thống yêu cầu nhập tên. |
| **Các ngoại lệ** | Mất kết nối khi tạo nhóm. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Mỗi nhóm phải có tên và ít nhất một quản trị viên. Chỉ admin mới có thể thêm/xóa thành viên và bộ thẻ. |
| **Các giả thuyết** | Người dùng muốn học tập theo nhóm hoặc chia sẻ tài liệu. |

---

## UC-13 – Khám phá từ vựng theo cấp độ CEFR

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-13 – Khám phá từ vựng theo cấp độ CEFR |
| **Mô tả** | Cho phép người dùng khám phá và học các bộ từ vựng tiếng Anh được phân cấp theo khung năng lực CEFR (A1, A2, B1, B2, C1, C2) có sẵn trong hệ thống. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Vocab API Service (dữ liệu từ vựng nội bộ) |
| **Sự kiện kích hoạt** | Người dùng chọn một cấp độ CEFR từ màn hình Khám phá trên trang chủ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Dữ liệu từ vựng theo cấp độ có sẵn trong hệ thống. |
| **Hậu điều kiện** | Người dùng xem và có thể học các bộ từ vựng theo cấp độ đã chọn. |
| **Luồng thông thường** | 1. Hệ thống hiển thị danh sách các cấp độ CEFR (A1 → C2). 2. Người dùng chọn cấp độ. 3. Hệ thống tải và hiển thị các bộ từ vựng theo cấp độ. 4. Người dùng chọn một bộ từ vựng để xem chi tiết. 5. Người dùng học từ vựng hoặc lưu về thư viện cá nhân. |
| **Luồng thay thế** | Không có bộ từ nào cho cấp độ được chọn → Hệ thống thông báo chưa có nội dung. |
| **Các ngoại lệ** | Lỗi tải dữ liệu từ vựng. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Bộ từ vựng được phân loại theo đúng chuẩn CEFR. Người dùng không thể chỉnh sửa bộ từ vựng hệ thống. |
| **Các giả thuyết** | Dữ liệu từ vựng CEFR đã được chuẩn bị và tích hợp sẵn trong ứng dụng. |

---

## UC-14 – Xem hồ sơ cá nhân & chuỗi học

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-14 – Xem hồ sơ cá nhân & chuỗi học |
| **Mô tả** | Cho phép người dùng xem thông tin cá nhân, thống kê học tập (số bộ thẻ, số thẻ từ), chuỗi học liên tiếp (streak) và lịch học trong tuần. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Auth, Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng nhấn vào tab Cá nhân trên thanh điều hướng dưới. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. |
| **Hậu điều kiện** | Thông tin hồ sơ và chuỗi học được hiển thị chính xác và cập nhật real-time. |
| **Luồng thông thường** | 1. Hệ thống tải thông tin người dùng từ Firebase Auth. 2. Hệ thống tải thống kê bộ thẻ từ Firestore. 3. Hệ thống tải dữ liệu chuỗi học từ Firestore (streams/{uid}). 4. Hiển thị avatar, tên, số bộ thẻ, số thẻ từ, số ngày streak. 5. Hiển thị thẻ thành tựu streak và lịch học 7 ngày trong tuần. |
| **Luồng thay thế** | Người dùng chưa có ngày học nào → Hiển thị trạng thái streak = 0 và lịch trống. |
| **Các ngoại lệ** | Lỗi tải dữ liệu streak từ Firestore. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Streak tăng 1 mỗi khi người dùng hoàn thành ít nhất một phiên học trong ngày. Bỏ qua một ngày không học → streak về 0. Lịch hiển thị đúng 7 ngày của tuần hiện tại. |
| **Các giả thuyết** | Người dùng muốn theo dõi tiến độ và duy trì thói quen học đều đặn. |

---

## UC-15 – Cài đặt tài khoản & ứng dụng

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-15 – Cài đặt tài khoản & ứng dụng |
| **Mô tả** | Cho phép người dùng xem và cập nhật thông tin cá nhân (tên hiển thị), chuyển đổi giao diện sáng/tối và bật/tắt hiệu ứng âm thanh trong ứng dụng. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Auth, Firebase Firestore, SharedPreferences |
| **Sự kiện kích hoạt** | Người dùng chọn Cài đặt từ màn hình Hồ sơ cá nhân. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. |
| **Hậu điều kiện** | Thay đổi cài đặt được lưu và áp dụng ngay lập tức cho toàn bộ ứng dụng. |
| **Luồng thông thường** | 1. Người dùng truy cập màn hình Cài đặt. 2. Hệ thống hiển thị thông tin tài khoản (tên, email) và các tùy chọn cài đặt. 3a. Người dùng nhấn vào tên → bottom sheet chỉnh sửa tên hiển thị → lưu → cập nhật Firebase Auth và Firestore. 3b. Người dùng bật/tắt chế độ tối → ThemeMode thay đổi ngay lập tức trên toàn app, lưu vào SharedPreferences. 3c. Người dùng bật/tắt âm thanh → AudioService cập nhật trạng thái, lưu vào SharedPreferences. |
| **Luồng thay thế** | Tên mới trống → Hệ thống không lưu và thông báo lỗi. Người dùng hủy chỉnh sửa tên → Tên không thay đổi. |
| **Các ngoại lệ** | Lỗi cập nhật Firebase Auth khi đổi tên. Mất kết nối khi cập nhật Firestore. |
| **Độ ưu tiên** | Trung bình |
| **Các quy tắc nghiệp vụ** | Email không thể chỉnh sửa (chỉ hiển thị). Cài đặt giao diện và âm thanh được lưu cục bộ và khôi phục khi mở lại app. Thay đổi tên hiển thị áp dụng ngay lập tức trên tất cả màn hình. |
| **Các giả thuyết** | Thiết bị có đủ bộ nhớ để lưu SharedPreferences. Firebase Auth cho phép cập nhật displayName. |

---

## UC-16 – Đăng xuất

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-16 – Đăng xuất |
| **Mô tả** | Cho phép người dùng kết thúc phiên làm việc hiện tại, xóa trạng thái đăng nhập khỏi thiết bị và quay về màn hình đăng nhập để bảo vệ thông tin tài khoản. |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Authentication |
| **Sự kiện kích hoạt** | Người dùng nhấn nút Đăng xuất trên màn hình Hồ sơ cá nhân. |
| **Tiền điều kiện** | Người dùng đang đăng nhập vào hệ thống. |
| **Hậu điều kiện** | Phiên đăng nhập bị xóa. Người dùng bị chuyển về màn hình Đăng nhập. Không thể truy cập các chức năng yêu cầu xác thực. |
| **Luồng thông thường** | 1. Người dùng nhấn nút Đăng xuất trên màn hình Hồ sơ. 2. Hệ thống hiển thị xác nhận đăng xuất. 3. Người dùng xác nhận. 4. Hệ thống gọi Firebase Auth signOut(). 5. Firebase xóa token xác thực khỏi thiết bị. 6. GoRouter tự động redirect về màn hình Đăng nhập. |
| **Luồng thay thế** | Người dùng hủy xác nhận → Ở lại màn hình hiện tại, phiên đăng nhập không thay đổi. |
| **Các ngoại lệ** | Lỗi mạng khi gọi Firebase signOut() → Hệ thống thông báo lỗi, phiên đăng nhập vẫn còn hiệu lực. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Sau khi đăng xuất, mọi dữ liệu cục bộ nhạy cảm phải được xóa. Router tự động bảo vệ các route yêu cầu xác thực — người dùng chưa đăng nhập sẽ bị redirect về /login. |
| **Các giả thuyết** | Firebase Authentication hoạt động bình thường. Ứng dụng sử dụng persistent auth state để phát hiện trạng thái đăng xuất. |

---

## UC-17 – Theo dõi tiến độ học tập

| Trường | Nội dung |
|---|---|
| **Số và tên UC** | UC-17 – Theo dõi tiến độ học tập |
| **Mô tả** | Hệ thống tự động ghi nhận và hiển thị tiến độ học tập của người dùng qua các chế độ học, bao gồm số từ đã học, tỉ lệ hoàn thành, lịch sử học và chuỗi ngày học liên tiếp (streak). |
| **Tác nhân chính** | Người dùng (học viên) |
| **Tác nhân phụ** | Firebase Firestore |
| **Sự kiện kích hoạt** | Người dùng hoàn thành một phiên học (Learn, Test, Match, Flashcard, Flappy Bird) hoặc truy cập màn hình Hồ sơ. |
| **Tiền điều kiện** | Người dùng đã đăng nhập. Người dùng đã hoàn thành ít nhất một phiên học. |
| **Hậu điều kiện** | Tiến độ học tập được lưu vào Firestore. Streak được cập nhật nếu là lần học đầu tiên trong ngày. Thống kê hiển thị chính xác trên màn hình Hồ sơ. |
| **Luồng thông thường** | 1. Người dùng hoàn thành một phiên học. 2. Hệ thống lưu kết quả phiên học (số câu đúng/sai, thời gian) vào Firestore. 3. Hệ thống kiểm tra lastStudyDate trong Firestore. 4. Nếu chưa học hôm nay → tăng streak +1, cập nhật lastStudyDate và danh sách studiedDates. 5. Nếu đã học hôm nay → bỏ qua cập nhật streak (idempotent). 6. Hệ thống hiển thị thống kê cập nhật trên màn hình Hồ sơ (stream real-time). |
| **Luồng thay thế** | Người dùng bỏ qua một ngày không học → Khi học lại, hệ thống phát hiện lastStudyDate < hôm qua → reset streak về 1. |
| **Các ngoại lệ** | Lỗi Firestore khi ghi dữ liệu tiến độ → Tiến độ không được lưu, streak không cập nhật. Mất kết nối mạng trong lúc kết thúc phiên học. |
| **Độ ưu tiên** | Cao |
| **Các quy tắc nghiệp vụ** | Mỗi ngày chỉ tính một lần vào streak (dùng Firestore transaction để đảm bảo tính nguyên tử). Streak bị reset về 0 nếu bỏ qua ≥ 1 ngày. Lịch sử studiedDates chỉ lưu tối đa 90 ngày gần nhất. Tiến độ được lưu riêng cho từng bộ thẻ (progress/{uid}/{deckId}). |
| **Các giả thuyết** | Đồng hồ thiết bị của người dùng chính xác để tính ngày học. Firebase Firestore transaction đảm bảo không xảy ra race condition khi cập nhật streak. |
