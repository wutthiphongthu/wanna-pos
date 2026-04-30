# ออกแบบ PPOS สำหรับการย้ายไปใช้ Firebase

เอกสารนี้อธิบายโครงสร้าง Firestore / Firebase Auth ที่สอดคล้องกับข้อมูลปัจจุบัน (แยกตามร้าน, เจ้าของ/พนักงาน) เพื่อให้ย้ายฐานข้อมูลจาก SQLite (Floor) ไป Firebase ได้โดยไม่สับสน

---

## 1. โครงสร้าง Firestore (แยกตามร้าน)

ข้อมูลแยกตาม `storeId` โดยใช้ **subcollections ใต้ stores** เพื่อให้ Security Rules และ query ง่าย

```
/stores/{storeId}                    # ข้อมูลร้าน
  - name, address, phone, isActive, createdAt, updatedAt

/stores/{storeId}/products/{productId}
  - productCode, name, productSubname, description, price, cost,
  - discountType, discount, stockQuantity, minStockLevel, category, categoryId,
  - barcode, barcodeType, customBarcodeId, hideInEcommerce, nonVat, unlimitedStock,
  - hideInEMenu, productLocation, imageUrls (array), isActive, createdAt, updatedAt

/stores/{storeId}/members/{memberId}
  - memberCode, name, email, phone, membershipLevel, points, isActive, createdAt, updatedAt

/stores/{storeId}/categories/{categoryId}
  - name, description, iconName, color, isActive, createdAt, updatedAt

/stores/{storeId}/sales/{saleId}
  - saleId, customerId, totalAmount, paymentMethod, status, createdAt, updatedAt
```

- **storeId**: ใช้เป็น document ID ของร้าน (หรือใช้ auto ID แล้วเก็บ storeId ใน field ก็ได้)
- **productId, memberId, categoryId, saleId**: ใช้ Firestore auto ID หรือเก็บ ID เดิมจาก SQLite ตอน migrate

---

## 2. Firebase Authentication + บทบาท/ร้าน

- **Firebase Auth**: ใช้สำหรับ login (อีเมล/รหัสผ่าน หรือโทรศัพท์)
- **บทบาทและร้าน**: เก็บใน Firestore เพื่อให้ Security Rules อ่านได้

```
/users/{uid}                         # หนึ่ง document ต่อ user (uid จาก Firebase Auth)
  - email, displayName, role         # 'owner' | 'employee'
  - storeId                          # ร้านที่ผูกกับ user นี้
  - storeName                        # cache ชื่อร้าน (optional)
  - createdAt, updatedAt
```

หรือใช้ **Custom Claims** (ถ้าไม่ต้องการอ่าน Firestore ทุกครั้ง):

- หลัง login อ่าน `/users/{uid}` แล้ว set custom claims: `{ role, storeId }`
- Client อ่าน `idTokenResult.claims` เพื่อรู้ role / storeId

---

## 3. Security Rules (แนวคิด)

- เฉพาะ user ที่ login แล้ว และมี `storeId` ใน `/users/{uid}` ถึงจะอ่าน/เขียนได้เฉพาะร้านนั้น

```javascript
// ตัวอย่างแนวทาง (ปรับรายละเอียดตามจริง)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    function isStoreMember(storeId) {
      return request.auth != null &&
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.storeId == storeId;
    }
    match /stores/{storeId} {
      allow read, write: if isStoreMember(storeId);
      match /products/{id} { allow read, write: if isStoreMember(storeId); }
      match /members/{id} { allow read, write: if isStoreMember(storeId); }
      match /categories/{id} { allow read, write: if isStoreMember(storeId); }
      match /sales/{id} { allow read, write: if isStoreMember(storeId); }
    }
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 4. การแมปกับโค้ดปัจจุบัน

| สิ่งที่ใช้อยู่ (SQLite / Local)                          | เมื่อย้ายไป Firebase                                                         |
| -------------------------------------------------------- | ---------------------------------------------------------------------------- |
| `AuthService` (login, getCurrentUser, getCurrentStoreId) | `FirebaseAuth` + อ่าน `/users/{uid}` หรือ Custom Claims                      |
| `ProductRepository` → `ProductRepositoryImpl` (Floor)    | `ProductRepositoryFirebaseImpl` อ่าน/เขียน `stores/{storeId}/products`       |
| `MemberRepository` → `MemberRepositoryImpl`              | `MemberRepositoryFirebaseImpl` → `stores/{storeId}/members`                  |
| `CategoryService` (ใช้ CategoryDao)                      | `CategoryRepository` + Firebase impl → `stores/{storeId}/categories`         |
| Sales (ถ้ามีใช้ SaleDao)                                 | `SalesRepositoryFirebaseImpl` → `stores/{storeId}/sales`                     |
| `LoyaltyPointsConfigService` (SharedPreferences)         | เก็บใน `stores/{storeId}/settings/loyalty` หรือ `/stores/{storeId}` เป็น map |

- **Bloc / UI**: ไม่ต้องเปลี่ยน ยังใช้ repository interface เดิม (เช่น `ProductRepository`) แค่สลับ implementation ผ่าน DI เป็น Firebase
- **Model**: ใช้ `ProductModel`, `MemberModel`, `CategoryModel` เดิม แปลงจาก/เป็น Firestore document ใน Firebase impl

---

## 5. ขั้นตอนเมื่อพร้อมย้าย

1. เพิ่ม package: `firebase_core`, `cloud_firestore`, `firebase_auth`
2. ตั้งค่า Firebase project (Android/iOS/Web) และเรียก `Firebase.initializeApp()` ใน `main.dart`
3. สร้าง `AuthService` รุ่น Firebase (หรือ `FirebaseAuthService`) ที่ login ผ่าน `FirebaseAuth` และโหลด `/users/{uid}` สำหรับ role/storeId
4. สร้าง repository implementations ที่อ่าน/เขียน Firestore ตาม path ด้านบน (ใช้ `getCurrentStoreId()` จาก AuthService เหมือนเดิม)
5. ใช้ `AppDataSource` (หรือ config) สลับ inject ระหว่าง SQLite impl กับ Firebase impl
6. (Optional) ทำ migration script อ่านข้อมูลจาก SQLite แล้วเขียนเข้า Firestore ตามโครงสร้างนี้

---

## 6. โฟลเดอร์และ config ที่มีอยู่แล้ว (เผื่อ Firebase)

ในโปรเจกต์มีแล้ว:

- **`lib/core/config/app_data_source.dart`** — enum `AppDataSource { sqlite, firebase }` และ `AppConfig.dataSource` / `AppConfig.useFirebase` ใช้สลับแหล่งข้อมูล
- **`lib/core/firebase/firebase_app.dart`** — `initializeFirebaseIfNeeded()` เรียกใน `main.dart` แล้ว; เมื่อเพิ่ม `firebase_core` ให้ uncomment `Firebase.initializeApp()` ในไฟล์นี้
- **`lib/core/firebase/firestore_paths.dart`** — path helpers สำหรับ Firestore ตามโครงสร้างด้านบน (เช่น `FirestorePaths.storeProducts(storeId)`)

โฟลเดอร์ที่แนะนำเมื่อย้าย:

```
lib/
  core/
    config/
      app_data_source.dart     # มีแล้ว
    firebase/
      firebase_app.dart        # มีแล้ว
      firestore_paths.dart     # มีแล้ว
  features/
    auth/
      data/
        auth_service_impl_firebase.dart  # สร้างเมื่อย้าย
    stock/
      data/
        product_repository_impl_firebase.dart  # สร้างเมื่อย้าย
```

เมื่อพร้อมใช้ Firebase:

1. ใน `pubspec.yaml` uncomment: `firebase_core`, `cloud_firestore`, `firebase_auth` แล้วรัน `flutter pub get` และ `flutterfire configure`
2. ใน `firebase_app.dart` uncomment การเรียก `Firebase.initializeApp()`
3. เปลี่ยน `AppConfig.dataSource` เป็น `AppDataSource.firebase`
4. สร้าง repository/auth implementations รุ่น Firebase และสลับ binding ใน DI ตาม `AppConfig.useFirebase` (เช่น ใช้ `@Environment` หรือ conditional registration ใน injector)
