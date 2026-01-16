# 🎓 University QA System - Hệ thống Hỏi đáp Đại học

<div align="center">

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=for-the-badge&logo=fastapi&logoColor=white)
![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![OpenAI](https://img.shields.io/badge/OpenAI-412991?style=for-the-badge&logo=openai&logoColor=white)

</div>

## 📋 Mục lục
- [Giới thiệu](#-giới-thiệu)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Kiến trúc Frontend](#-kiến-trúc-frontend)
- [Phân quyền và Chức năng](#-phân-quyền-và-chức-năng)
- [Hướng dẫn cài đặt](#-hướng-dẫn-cài-đặt)

---

## 🎯 Giới thiệu

**University QA System** là hệ thống hỏi đáp thông minh dành cho học sinh, sinh viên. Hệ thống sử dụng công nghệ AI/LLM để trả lời các câu hỏi liên quan đến quy định, chính sách, học bổng, và các thông tin học thuật của trường.

### ✨ Tính năng chính:
- 🤖 **Chatbot AI** - Trả lời câu hỏi tự động dựa trên tài liệu chính thức của trường
- 📚 **Quản lý tài liệu** - Upload, phân loại và quản lý các văn bản, quy định
- ❓ **Câu hỏi phổ biến** - Hiển thị và quản lý các câu hỏi thường gặp
- 📊 **Dashboard thống kê** - Theo dõi hoạt động hỏi đáp
- 👥 **Quản lý người dùng** - Phân quyền và quản lý tài khoản
- 🔑 **Quản lý API Keys** - Quản lý các key LLM (OpenAI, Google)

---

### Video Demo
https://drive.google.com/file/d/1WOpQhMdRMpa5lw2iYpUWVpM-yY5sWYAe/view?usp=sharing


## 🛠 Công nghệ sử dụng

### Frontend (Mobile App)
| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| **Flutter** | ^3.10.4 | Framework phát triển ứng dụng đa nền tảng |
| **Dart** | ^3.10.4 | Ngôn ngữ lập trình |
| **flutter_bloc** | ^9.1.1 | State Management |
| **go_router** | ^17.0.1 | Navigation/Routing |
| **dio** | ^5.9.0 | HTTP Client |
| **get_it** | ^9.2.0 | Dependency Injection |
| **fpdart** | ^1.2.0 | Functional Programming |
| **flutter_secure_storage** | ^10.0.0 | Lưu trữ bảo mật |
| **syncfusion_flutter_pdfviewer** | ^32.1.20 | Xem file PDF |
| **webview_flutter** | ^4.13.0 | WebView tích hợp |

### Backend (API Server)
| Công nghệ | Mục đích |
|-----------|----------|
| **FastAPI** | Web Framework Python hiệu suất cao |
| **Uvicorn** | ASGI Server |
| **MongoDB** | Database NoSQL |
| **ChromaDB** | Vector Database cho Embedding |
| **Motor** | Async MongoDB Driver |
| **PyMongo** | MongoDB Driver |

### AI/ML Stack
| Công nghệ | Mục đích |
|-----------|----------|
| **OpenAI API** | LLM cho việc trả lời câu hỏi |
| **Google Generative AI** | LLM alternative |
| **Sentence Transformers** | Text Embedding |
| **LangChain** | Text Splitters cho chunking |
| **PyMuPDF, PDFPlumber** | Xử lý file PDF |
| **Tesseract OCR** | Trích xuất text từ ảnh |

### DevOps & Infrastructure
| Công nghệ | Mục đích |
|-----------|----------|
| **Docker** | Containerization |
| **Docker Compose** | Container Orchestration |

---

## 🏗 Kiến trúc Frontend

### Clean Architecture + Feature-First Structure

```
frontend/lib/
├── core/                          # Core modules dùng chung
│   ├── common/                    # Widgets, constants chung
│   ├── config/                    # Cấu hình app (routes, themes)
│   ├── error/                     # Exception & Failure handling
│   ├── network/                   # Network layer (interceptors)
│   ├── services/                  # Services (storage, etc.)
│   ├── use_case/                  # Base UseCase class
│   └── utils/                     # Utilities
│
├── features/                      # Feature modules
│   ├── authentication/            # Đăng nhập, đăng ký
│   ├── chat_box/                  # Chatbot hỏi đáp
│   ├── dashboard/                 # Dashboard thống kê
│   ├── document/                  # Quản lý tài liệu
│   ├── popular_question/          # Câu hỏi phổ biến
│   ├── user_management/           # Quản lý người dùng
│   └── api_management/            # Quản lý API Keys
│
├── init_dependencies.dart         # Dependency Injection setup
└── main.dart                      # Entry point
```

### Cấu trúc mỗi Feature (Clean Architecture)

```
feature_name/
├── data/                          # Data Layer
│   ├── data_sources/              # Remote/Local data sources
│   ├── models/                    # Data models (DTO)
│   └── repositories/              # Repository implementations
│
├── domain/                        # Domain Layer (Business Logic)
│   ├── entities/                  # Business entities
│   ├── repositories/              # Repository interfaces
│   └── use_cases/                 # Use cases (interactors)
│
└── presentation/                  # Presentation Layer
    ├── bloc/                      # BLoC state management
    ├── pages/                     # Screen widgets
    └── widgets/                   # Reusable widgets
```

### State Management với BLoC Pattern

```
┌─────────────────────────────────────────────────────────────┐
│                         UI (Widget)                         │
│                              │                              │
│                    ┌─────────▼─────────┐                    │
│                    │   Add Event       │                    │
│                    └─────────┬─────────┘                    │
│                              │                              │
├──────────────────────────────┼──────────────────────────────┤
│                              ▼                              │
│  ┌──────────────────────────────────────────────────────┐   │
│  │                        BLoC                          │   │
│  │  ┌─────────┐    ┌────────────┐    ┌─────────────┐    │   │
│  │  │  Event  │ -> │  Process   │ -> │   State     │    │   │
│  │  └─────────┘    │  (UseCase) │    └─────────────┘    │   │
│  │                 └────────────┘                       │   │
│  └──────────────────────────────────────────────────────┘   │
│                              │                              │
│                    ┌─────────▼─────────┐                    │
│                    │   Emit State      │                    │
│                    └─────────┬─────────┘                    │
│                              │                              │
├──────────────────────────────┼──────────────────────────────┤
│                              ▼                              │
│                    UI Rebuilds với State mới                │
└─────────────────────────────────────────────────────────────┘
```

### Dependency Injection với GetIt

```dart
// Đăng ký dependencies theo layer
void _initFeature() {
  // Data Sources
  serviceLocator.registerFactory<RemoteDataSource>(() => RemoteDataSourceImpl(serviceLocator()));
  
  // Repositories
  serviceLocator.registerFactory<Repository>(() => RepositoryImpl(serviceLocator()));
  
  // Use Cases
  serviceLocator.registerFactory<UseCase>(() => UseCase(serviceLocator()));
  
  // BLoC
  serviceLocator.registerLazySingleton(() => FeatureBloc(serviceLocator()));
}
```

### Data Flow

```
┌──────────┐    ┌──────────┐    ┌────────────┐    ┌─────────────┐    ┌──────────┐
│    UI    │ -> │   BLoC   │ -> │  Use Case  │ -> │ Repository  │ -> │   API    │
│ (Widget) │    │  (Event) │    │            │    │   (Impl)    │    │ (Remote) │
└──────────┘    └──────────┘    └────────────┘    └─────────────┘    └──────────┘
     ▲                                                                     │
     │                                                                     │
     └─────────────────────── State (Either<Failure, Data>) ◄──────────────┘
```

---

## 👥 Phân quyền và Chức năng

### Các vai trò (Roles)

| Role | Mô tả |
|------|-------|
| **Student** | Sinh viên - người dùng cơ bản |
| **Faculty Manager** | Quản lý khoa - quản lý tài liệu và câu hỏi của khoa |
| **Admin** | Quản trị viên - toàn quyền hệ thống |

### Ma trận chức năng theo Role

| Chức năng | Student | Admin |
|-----------|:-------:|:-----:|
| **Chatbot hỏi đáp** | ✅ |  ✅ |
| **Xem lịch sử hỏi đáp** | ✅ | ✅ |
| **Xem tài liệu** | ✅ | ✅ |
| **Xem câu hỏi phổ biến** | ✅ | ✅ |
| **Dashboard thống kê** | ❌ | ✅ |
| **Quản lý tài liệu khoa** | ❌ | ✅ |
| **Quản lý câu hỏi phổ biến** | ❌ | ✅ |
| **Quản lý tất cả tài liệu** | ❌ | ✅ |
| **Quản lý người dùng** | ❌ | ✅ |
| **Quản lý API Keys** | ❌ | ✅ |
| **Phân quyền người dùng** | ❌ | ✅ |
| **Ban/Unban người dùng** | ❌ | ✅ |

### Chi tiết các Module chức năng

#### 1. 🔐 Authentication
- Đăng nhập với tài khoản ELIT (OAuth)
- Đăng nhập với tài khoản hệ thống
- Đăng ký tài khoản mới
- Xác thực và phân quyền tự động

#### 2. 🤖 Chat Box
- Đặt câu hỏi cho AI
- Nhận câu trả lời dựa trên tài liệu
- Gửi feedback (hữu ích/không hữu ích)
- Xem lịch sử hỏi đáp
- Xem chi tiết nguồn tham khảo

#### 3. 📊 Dashboard
- Thống kê số câu hỏi theo thời gian
- Thống kê theo khoa/ngành
- Xem các câu hỏi gần đây
- Biểu đồ phân tích

#### 4. 📚 Document Management
- Xem danh sách tài liệu (chung + theo khoa)
- Lọc theo loại, năm, khoa
- Xem PDF trực tiếp trong app
- Upload tài liệu mới (Admin/FM)
- Xóa/sửa tài liệu (Admin/FM)

#### 5. ❓ Popular Questions
- Xem danh sách câu hỏi phổ biến
- Tự động sinh câu hỏi từ AI
- Gán câu hỏi cho khoa
- Ẩn/hiện câu hỏi
- Chỉnh sửa nội dung câu hỏi

#### 6. 👥 User Management (Admin only)
- Xem danh sách người dùng
- Tìm kiếm theo tên, email
- Lọc theo role, khoa
- Phân quyền người dùng
- Ban/Unban tài khoản

#### 7. 🔑 API Management (Admin only)
- Xem danh sách API Keys (OpenAI, Google)
- Thêm API Key mới
- Kiểm tra key và lấy models khả dụng
- Chọn model sử dụng
- Bật/tắt key đang sử dụng
- Xóa API Key

---

## 🚀 Hướng dẫn cài đặt

### Yêu cầu hệ thống

- **Docker** & **Docker Compose**
- **Flutter SDK** ^3.10.4
- **Android Studio** / **VS Code** với Flutter extensions
- **Git**

### 1. Clone Repository

```bash
git clone https://github.com/your-username/University-QA-System.git
cd University-QA-System
```

### 2. Cấu hình Backend

#### 2.1. Tạo file môi trường

```bash
cp backend/.env.example backend/.env
```

#### 2.2. Chỉnh sửa file `backend/.env`

```env
# MongoDB
MONGO_URI=mongodb://mongodb:27017
MONGO_DATABASE=university_qa

# ChromaDB
CHROMA_HOST=chromadb
CHROMA_PORT=8000

# JWT Secret
JWT_SECRET=your-super-secret-key-here

# OpenAI (optional - có thể thêm qua app)
OPENAI_API_KEY=sk-xxx

# Google AI (optional)
GOOGLE_API_KEY=xxx
```

### 3. Khởi chạy Backend với Docker

```bash
# Build và chạy tất cả services
docker-compose -f docker-compose.dev.yml up --build

# Hoặc chạy ở background
docker-compose -f docker-compose.dev.yml up -d --build
```

Các services sẽ chạy tại:
- **Backend API**: http://localhost:8000
- **MongoDB**: localhost:27021
- **ChromaDB**: http://localhost:8001

### 4. Cấu hình Frontend

#### 4.1. Di chuyển vào thư mục frontend

```bash
cd frontend
```

#### 4.2. Cài đặt dependencies

```bash
flutter pub get
```

#### 4.3. Tạo file môi trường

```bash
# Tạo file .env trong thư mục frontend
echo "BASE_URL=http://10.0.2.2:8000" > .env
```

> **Lưu ý**: 
> - Android Emulator: sử dụng `10.0.2.2` để truy cập localhost của máy host
> - iOS Simulator: sử dụng `127.0.0.1`
> - Thiết bị thật: sử dụng IP của máy host (ví dụ: `192.168.1.100`)

### 5. Chạy ứng dụng Flutter

```bash
# Chạy trên emulator/simulator
flutter run

# Chạy trên thiết bị cụ thể
flutter run -d <device_id>

# Xem danh sách thiết bị
flutter devices
```

### 6. Build Production

#### Android APK

```bash
cd frontend
flutter build apk --release
```
---

## 📁 Cấu trúc thư mục Project

```
University-QA-System/
├── backend/                    # Backend FastAPI
│   ├── app/
│   │   ├── controllers/        # Business logic controllers
│   │   ├── daos/               # Data Access Objects
│   │   ├── databases/          # Database connections
│   │   ├── routes/             # API routes
│   │   ├── schemas/            # Pydantic schemas
│   │   ├── services/           # External services (AI, etc.)
│   │   ├── utils/              # Utilities
│   │   └── main.py             # FastAPI entry point
│   ├── requirements.txt
│   └── Dockerfile.dev
│
├── frontend/                   # Flutter Mobile App
│   ├── lib/
│   │   ├── core/               # Core modules
│   │   ├── features/           # Feature modules
│   │   ├── init_dependencies.dart
│   │   └── main.dart
│   ├── assets/                 # Images, icons
│   ├── pubspec.yaml
│   └── .env
│
├── uploads/                    # Uploaded documents
│   └── documents/
│
├── hf_cache/                   # HuggingFace model cache
│
├── docker-compose.dev.yml      # Docker Compose config
└── README.md
```

---


## 📞 Liên hệ

- **Email**: tanlxag116@gmail.com
- **Phone**: 0918356643
- **Project Link**: [https://github.com/Tan-1106/University-QA-System](https://github.com/Tan-1106/University-QA-System)

---
