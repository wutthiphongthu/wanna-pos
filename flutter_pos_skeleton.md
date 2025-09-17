# Flutter POS System - Complete Project Structure

This document outlines the complete structure and components of the Flutter POS (Point of Sale) system with authentication, category management, and stock management.

## Project Structure

```
lib/
├── core/
│   ├── di/
│   │   ├── injector.dart
│   │   └── injector.config.dart
│   ├── error/
│   │   └── failures.dart
│   ├── network/
│   │   ├── dio_client.dart
│   │   ├── network_info.dart
│   │   └── api_endpoints.dart
│   ├── usecase/
│   │   └── usecase.dart
│   └── utils/
│       ├── constants.dart
│       ├── validation.dart
│       ├── date_utils.dart
│       ├── currency_formatter.dart
│       ├── storage_service.dart
│       ├── secure_storage.dart
│       ├── notification_service.dart
│       ├── analytics_service.dart
│       ├── crashlytics_service.dart
│       ├── device_info.dart
│       ├── app_lifecycle_service.dart
│       ├── error_handler.dart
│       ├── theme.dart
│       └── routes.dart
├── database/
│   ├── app_database.dart
│   ├── app_database.g.dart
│   ├── database_service.dart
│   ├── entities/
│   │   ├── product_entity.dart
│   │   └── sale_entity.dart
│   └── daos/
│       ├── product_dao.dart
│       └── sale_dao.dart
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   │   ├── auth_bloc.dart
│   │   │   ├── auth_event.dart
│   │   │   └── auth_state.dart
│   │   ├── services/
│   │   │   └── auth_service.dart
│   │   ├── presentation/
│   │   │   └── pages/
│   │   │       ├── login_page.dart
│   │   │       ├── mode_selection_page.dart
│   │   │       └── auth_wrapper.dart
│   │   └── widgets/
│   │       └── logout_menu.dart
│   ├── categories/
│   │   ├── models/
│   │   │   └── category_model.dart
│   │   ├── services/
│   │   │   └── category_service.dart
│   │   ├── bloc/
│   │   │   ├── category_bloc.dart
│   │   │   ├── category_event.dart
│   │   │   └── category_state.dart
│   │   ├── pages/
│   │   │   └── category_management_page.dart
│   │   └── widgets/
│   │       ├── category_form_dialog.dart
│   │       └── category_quick_dialog.dart
│   ├── sales/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── datasources/
│   │   └── presentation/
│   │       ├── bloc/
│   │       │   └── sales_bloc.dart
│   │       ├── pages/
│   │       │   └── pos_main_page.dart
│   │       └── widgets/
│   ├── stock/
│   │   ├── models/
│   │   │   └── product_model.dart
│   │   ├── services/
│   │   │   └── product_service.dart
│   │   ├── repositories/
│   │   │   └── product_repository.dart
│   │   ├── usecases/
│   │   │   ├── create_product.dart
│   │   │   ├── update_product.dart
│   │   │   ├── delete_product.dart
│   │   │   ├── get_all_products.dart
│   │   │   ├── get_active_products.dart
│   │   │   ├── get_low_stock_products.dart
│   │   │   ├── get_product_by_id.dart
│   │   │   └── search_products.dart
│   │   ├── bloc/
│   │   │   ├── product_bloc.dart
│   │   │   ├── product_event.dart
│   │   │   └── product_state.dart
│   │   └── pages/
│   │       ├── stock_main_page.dart
│   │       ├── product_list_page.dart
│   │       ├── product_detail_page.dart
│   │       └── product_form_page.dart
│   ├── members/
│   │   └── members_page.dart
│   ├── payment/
│   │   └── payment_page.dart
│   ├── loyalty/
│   │   └── loyalty_page.dart
│   ├── backend/
│   │   └── presentation/
│   │       └── pages/
│   │           └── backend_main_page.dart
│   └── dashboard/
│       └── presentation/
│           └── pages/
│               └── dashboard_page.dart
└── main.dart
```

## 🎯 Key Features

### 🔐 Authentication System

- **Persistent Login**: จำการ login จนกว่าจะ logout
- **User Roles**: Admin และ Cashier
- **Session Management**: ใช้ SharedPreferences เก็บ session
- **Auto Navigation**: ตรวจสอบ login state อัตโนมัติ
- **Logout Functionality**: ปุ่ม logout ในทุกหน้า

**Demo Credentials:**

- Admin: `admin/1234`
- Cashier: `cashier/1234`

### 🏷️ Category Management

- **Full Management Page**: หน้าจัดการหมวดหมู่แบบเต็มหน้าจอ
- **Quick Access Dialog**: Dialog เปิดได้จากทุกหน้า
- **Icon & Color Selection**: เลือกไอคอนและสี 10 แบบ
- **Search & Filter**: ค้นหาและกรองหมวดหมู่
- **CRUD Operations**: เพิ่ม/แก้ไข/ลบ/เปิด-ปิดใช้งาน
- **Integration**: เชื่อมต่อกับระบบสินค้า

### 📦 Stock Management

- **Product CRUD**: เพิ่ม/แก้ไข/ลบ/ดูรายละเอียดสินค้า
- **Inventory Tracking**: ติดตามสต็อกสินค้า
- **Low Stock Alerts**: แจ้งเตือนสินค้าใกล้หมด
- **Product Search**: ค้นหาและกรองสินค้า
- **Category Integration**: เลือกหมวดหมู่เมื่อเพิ่ม/แก้ไขสินค้า
- **Multi-tab Interface**: สินค้าทั้งหมด/ภาพรวม/ใกล้หมด

### 💰 Sales Management

- Product selection and cart management
- Payment processing
- Receipt generation

### 👥 Member Management

- Customer information
- Loyalty program integration

### ⚙️ Backend Management

- Administrative functions
- **Category Management**: จัดการหมวดหมู่สินค้า
- **Stock Management**: จัดการสินค้า
- Data management
- System configuration

### 📊 Dashboard

- Sales analytics
- Performance metrics
- Quick overview

## 🔧 Technical Implementation

### State Management

- **BLoC Pattern**: ใช้ flutter_bloc สำหรับ state management
- **Dependency Injection**: ใช้ get_it และ injectable
- **Persistent Storage**: SharedPreferences สำหรับ session
- **Provider Integration**: BlocProvider.value สำหรับการนำทาง

### Navigation & UI

- **Route-based Navigation**: ใช้ named routes
- **AuthWrapper**: ตรวจสอบ authentication อัตโนมัติ
- **Responsive Design**: รองรับหน้าจอขนาดต่างๆ
- **Material Design 3**: ใช้ Material 3 components

### Data Layer

- **Mock Services**: ใช้ mock data สำหรับ development
- **Repository Pattern**: แยก data layer ออกจาก business logic
- **Future-ready**: พร้อมเชื่อมต่อ API จริง
- **Error Handling**: จัดการ error แบบ centralized

## 🚀 Usage Flow

### Authentication Flow

1. **App Launch** → ตรวจสอบ session อัตโนมัติ
2. **If Logged In** → Mode Selection Page
3. **If Not Logged In** → Login Page
4. **After Login** → บันทึก session → Mode Selection
5. **Logout** → ลบ session → Login Page

### Category Management Flow

1. **Backend Management** → "จัดการหมวดหมู่" card → หน้าจัดการเต็ม
2. **Quick Access** → กดไอคอน category ใน AppBar → dialog จัดการด่วน
3. **Product Form** → เลือกหมวดหมู่เมื่อเพิ่ม/แก้ไขสินค้า

### Stock Management Flow

1. **Mode Selection** → "จัดการหลังบ้าน" → "จัดการสินค้า"
2. **Product List** → ดู/ค้นหา/กรองสินค้า
3. **Add/Edit Product** → เลือกหมวดหมู่ + กรอกข้อมูล
4. **Product Detail** → ดูรายละเอียดและแก้ไข

## 📋 Current Status

### ✅ Completed Features

- ✅ Authentication system with persistent login
- ✅ Category management (full page + dialog)
- ✅ Stock management with CRUD operations
- ✅ Product form with category selection
- ✅ Backend management interface
- ✅ Logout functionality across all pages
- ✅ Responsive UI with Material Design 3

### 🚧 In Development

- Product form category integration (in progress)

### 📝 Planned Features

- Sales management integration
- Member management system
- Payment processing
- Loyalty program
- Dashboard analytics
- Report generation

---

## 🛠️ Development Notes

- **Clean Architecture**: แบ่งชั้น `data`, `domain`, `presentation`
- **BLoC Pattern**: ใช้สำหรับ state management (`flutter_bloc`)
- **Floor Database**: Local database (offline-first)
- **GetIt**: Dependency Injection container (`injectable`)
- **Feature-based Structure**: แยกตาม feature (auth, categories, stock, sales, etc.)
- **Mock Data**: ใช้ mock services สำหรับ development
- **Thai Language**: UI ใช้ภาษาไทยทั้งหมด

---
