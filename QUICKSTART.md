# SportLife - Ứng dụng Dự đoán Thể thao

## 🚀 Khởi động nhanh

### Yêu cầu hệ thống

- **Laragon** với PHP 8.1+ và MySQL 8.0+ (đã cài tại `E:\laragon`)
- **Flutter SDK** 3.24+
- **Git**

### Các file batch để chạy ứng dụng

| File                 | Mô tả                                                   |
| -------------------- | ------------------------------------------------------- |
| `start_app.bat`      | Khởi động toàn bộ ứng dụng (Backend + hướng dẫn Mobile) |
| `start_backend.bat`  | Chỉ khởi động Laravel Backend API                       |
| `start_mobile.bat`   | Chạy Flutter Mobile App (chọn platform)                 |
| `setup_database.bat` | Reset và seed lại database                              |

### Bước 1: Khởi động Laragon

1. Mở Laragon
2. Click **"Start All"** để khởi động MySQL

### Bước 2: Chạy ứng dụng

```batch
# Cách 1: Chạy toàn bộ
start_app.bat

# Cách 2: Chạy riêng Backend
start_backend.bat

# Cách 3: Chạy riêng Mobile
start_mobile.bat
```

## 📱 Tài khoản đăng nhập

### Admin

- **Email:** admin@sportlife.vn
- **Password:** password123
- **Quyền:** Toàn quyền quản trị

### Demo User

- **Email:** demo@sportlife.vn
- **Password:** demo123
- **Quyền:** Người dùng thường

### Test Users

- vana@gmail.com, thib@gmail.com, vanc@gmail.com...
- **Password:** password123

## 🔗 API Endpoints

- **Base URL:** http://127.0.0.1:8000
- **API Version:** v1
- **Full API:** http://127.0.0.1:8000/api/v1/

### Một số endpoints chính:

```
GET  /api/v1/competitions      - Danh sách giải đấu
GET  /api/v1/matches           - Danh sách trận đấu
GET  /api/v1/teams             - Danh sách đội bóng
POST /api/v1/auth/login        - Đăng nhập
POST /api/v1/auth/register     - Đăng ký
GET  /api/v1/predictions       - Dự đoán của user
```

## 📂 Cấu trúc dự án

```
SportLife/
├── backend/           # Laravel 10 API
│   ├── app/
│   │   ├── Http/Controllers/Api/    # API Controllers
│   │   ├── Models/                   # Eloquent Models
│   │   └── ...
│   ├── database/
│   │   ├── migrations/               # Database migrations
│   │   └── seeders/                  # Data seeders
│   └── routes/api.php                # API routes
│
├── mobile/            # Flutter App
│   ├── lib/
│   │   ├── core/                     # Core utilities
│   │   ├── features/                 # Feature modules
│   │   └── main.dart                 # Entry point
│   └── pubspec.yaml                  # Dependencies
│
├── start_app.bat       # Khởi động toàn bộ
├── start_backend.bat   # Khởi động Backend
├── start_mobile.bat    # Khởi động Mobile
└── setup_database.bat  # Setup database
```

## ⚙️ Cấu hình

### Backend (.env)

```env
APP_URL=http://127.0.0.1:8000
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sportlife
DB_USERNAME=root
DB_PASSWORD=
```

### Mobile (lib/core/config/app_config.dart)

```dart
static const String apiBaseUrl = 'http://127.0.0.1:8000/api/v1';
```

## 🔧 Xử lý sự cố

### MySQL không chạy

1. Mở Laragon
2. Click "Start All"
3. Kiểm tra port 3306

### API trả về 404

```batch
cd backend
php artisan route:clear
php artisan cache:clear
```

### Flutter không build được

```batch
cd mobile
flutter clean
flutter pub get
```

## 📝 License

Private Project - SportLife Team
