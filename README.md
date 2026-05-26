# 🎮 QLNetAppMobile (Quản Lý Tiệm Net)

QLNetAppMobile là một ứng dụng di động được xây dựng bằng **Flutter**, thiết kế chuyên biệt để hỗ trợ quản lý phòng máy (Cyber Gaming / Tiệm Net). Ứng dụng giúp chủ phòng máy và người chơi dễ dàng tương tác, theo dõi tài khoản, gọi dịch vụ và nạp tiền một cách tiện lợi ngay trên điện thoại.

## ✨ Tính năng nổi bật

### Dành cho Khách hàng (Users)
* **🔐 Tài khoản & Bảo mật:** Đăng nhập, đăng ký tài khoản mới, xác thực qua Email OTP và cập nhật hồ sơ cá nhân.
* **💻 Theo dõi máy trạm:** Xem danh sách máy tính trống/đang sử dụng và chi tiết cấu hình máy.
* **🍜 Dịch vụ & Đồ ăn:** Xem menu, đặt đồ ăn/thức uống và các dịch vụ khác trực tiếp từ ứng dụng.
* **💳 Thanh toán & Nạp tiền:** Hỗ trợ nạp tiền vào tài khoản và thanh toán giờ chơi an toàn.
* **💬 Nhắn tin:** Giao tiếp nhanh chóng với thu ngân hoặc quản trị viên.

### Dành cho Quản trị viên (Admin)
* **👥 Quản lý người dùng:** Xem danh sách, tạo mới và quản lý tài khoản người chơi.
* **🖥️ Quản lý phòng máy:** Quản lý tình trạng máy trạm (Bật/Tắt/Đang bảo trì).
* **📦 Quản lý dịch vụ:** Thêm, sửa, xóa các mặt hàng trong menu và dịch vụ của tiệm.
* **📊 Thống kê & Báo cáo:** Xem biểu đồ, doanh thu và các số liệu phân tích hoạt động kinh doanh.

## 🛠️ Công nghệ sử dụng

* **Framework:** [Flutter](https://flutter.dev/) (Dart)
* **Kiến trúc:** Phân chia thư mục rõ ràng theo mô hình MVC (API Controllers, Entities, Screens, Widgets).
* **Kết nối API:** Giao tiếp với Backend qua RESTful API (`api_client.dart`).

## 📁 Cấu trúc thư mục chính

```text
lib/
├── api/          # Các file điều khiển giao tiếp API (account, computer, menu...)
├── entities/     # Các mô hình dữ liệu (models)
├── Funtions/     # Các hàm xử lý logic dùng chung (deposit, message...)
├── screen/       # Giao diện người dùng
│   ├── Admin/    # Màn hình dành riêng cho quản lý
│   └── General/  # Màn hình chung (Đăng nhập, Trang chủ, Nạp tiền...)
└── widget/       # Các thành phần UI có thể tái sử dụng (Appbar, Button, Chart...)
