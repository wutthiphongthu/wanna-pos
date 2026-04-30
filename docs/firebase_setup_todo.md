# Firebase Connect — Plan & Todo

แผนเชื่อมต่อ Firebase กับ PPOS ตาม [firebase_design.md](./firebase_design.md)  
ทำทีละขั้นแล้วติ๊กเมื่อเสร็จ

---

## Phase 1: Project & packages

- [ ] **1.1** สร้าง/เลือก Firebase project ที่ [Firebase Console](https://console.firebase.google.com/)
- [ ] **1.2** เปิดใช้ **Authentication** (Email/Password หรือวิธีที่ใช้)
- [ ] **1.3** เปิดใช้ **Cloud Firestore** (สร้าง DB ในโหมดที่ต้องการ)
- [ ] **1.4** ติดตั้ง FlutterFire CLI (ถ้ายังไม่มี):  
  `dart pub global activate flutterfire_cli`
- [ ] **1.5** รันในโฟลเดอร์โปรเจกต์:  
  `flutterfire configure`  
  (จะสร้าง/ลิงก์ Android + iOS + เลือก project แล้วสร้าง `lib/firebase_options.dart`)
- [x] **1.6** ใน `pubspec.yaml` uncomment packages แล้วรัน `flutter pub get`:
  ```yaml
  firebase_core: ^3.8.1
  cloud_firestore: ^5.5.0
  firebase_auth: ^5.3.4
  ```
- [ ] **1.7** เพิ่ม `firebase_options.dart` ใน `.gitignore` ได้ถ้าไม่ต้องการ commit (หรือ commit ไว้เพื่อให้ทีม build ได้)

---

## Phase 2: Initialize Firebase ในแอป

- [x] **2.1** ใน `lib/core/firebase/firebase_app.dart`:
  - เพิ่ม `import 'package:firebase_core/firebase_core.dart';`
  - เพิ่ม `import '../../firebase_options.dart';` (path ตามที่ `flutterfire configure` สร้าง)
  - เรียก `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
- [ ] **2.2** รันแอปแล้วตรวจว่าไม่มี error ตอนสตาร์ท (ตอนนี้ยังใช้ SQLite เพราะ `AppConfig.dataSource` ยังเป็น `sqlite`)

---

## Phase 3: Auth + User profile (Firestore) ✅

- [x] **3.1** สร้าง `lib/features/auth/services/auth_service_firebase.dart`:
  - ใช้ `FirebaseAuth` signInWithEmailAndPassword / signOut
  - หลัง login อ่าน `/users/{uid}` จาก Firestore เพื่อเอา `storeId`, `role`, `storeName`, `displayName`
  - implement `IAuthService`: `getCurrentStoreId()`, `getCurrentUser()`, `isLoggedIn()`, `login`, `logout`
  - **เมื่อใช้ Firebase ให้ใส่อีเมลในช่อง "username" ที่หน้า login** (Firebase Auth ใช้ email/password)
- [x] **3.2** ใน Firestore สร้าง collection `users` และใส่ document ตาม uid ของ user ที่สมัครใน Authentication:
  - path: `users/{uid}` (uid = Firebase Auth UID)
  - fields: `email`, `displayName` (หรือ `userFullName`), `role` ('owner'|'employee'), `storeId`, `storeName`, `createdAt`, `updatedAt`
- [x] **3.3** DI: ใช้ `IAuthService` + ลงทะเบียนใน `configureDependencies()` — เมื่อ `AppConfig.useFirebase` ใช้ `AuthServiceFirebase` ไม่เช่นนั้นใช้ `AuthService`

**สร้าง user ครั้งแรก:** ใน Firebase Console → Authentication → สมัครผู้ใช้ (อีเมล/รหัสผ่าน) → copy UID → Firestore → เริ่ม collection `users` → เพิ่ม document โดยใช้ UID เป็น document ID → ใส่ field ตาม 3.2

---

## Phase 4: Firestore structure & Security Rules ✅

- [x] **4.1** สร้าง collection ตาม design (หรือให้สร้างอัตโนมัติตอนเขียนข้อมูล):
  - `stores/{storeId}` — ข้อมูลร้าน
  - `stores/{storeId}/products/{productId}`
  - `stores/{storeId}/members/{memberId}`
  - `stores/{storeId}/categories/{categoryId}`
  - `stores/{storeId}/sales/{saleId}` (+ subcollection `line_items`)
  - `stores/{storeId}/settings/loyalty` — ตั้งค่าสะสมคะแนน
- [x] **4.2** เขียน Security Rules ใน `firestore.rules` (ให้ user อ่าน/เขียนได้เฉพาะร้านของตัวเอง ตาม `users/{uid}.storeId`)

---

## Phase 5: Repository implementations (Firebase) ✅

ทำทีละ feature แล้วทดสอบ:

- [x] **5.1** Products: `ProductRepositoryFirebaseImpl` — อ่าน/เขียน Firestore ผ่าน `FirestorePaths.storeProducts(storeId)`
- [x] **5.2** Categories: `CategoryServiceFirebase` implements `ICategoryService`
- [x] **5.3** Members: `MemberRepositoryFirebaseImpl` — `stores/{storeId}/members`
- [x] **5.4** Sales + line items: `SalesRepositoryFirebaseImpl` — `stores/{storeId}/sales/{saleId}` + subcollection `line_items`
- [x] **5.5** Loyalty config: `LoyaltyPointsConfigServiceFirebase` — `stores/{storeId}/settings/loyalty`
- [x] **5.6** DI: ใน `injector.dart` เมื่อ `AppConfig.useFirebase` สลับ ISalesRepository, ProductRepository, MemberRepository, ICategoryService, ILoyaltyPointsConfigService เป็น impl รุ่น Firebase

---

## Phase 6: โหมดข้อมูลหลัก (SQLite vs Firestore ตรง)

- [x] **6.0** โหมดหลัก: **offline-first** — `AppConfig.dataSource = AppDataSource.sqlite` ใน `lib/core/config/app_data_source.dart`  
  SQLite เป็นความจริงหลัก; Firebase Auth + ซิงก์สินค้า (SQLite ↔ Firestore) ผ่าน `SyncManager` / `ProductSyncService`
- [ ] **6.1** (ทางเลือก / legacy) ตั้ง `dataSource = AppDataSource.firebase` เมื่อต้องการให้ repository ชี้ Firestore โดยตรง (ไม่ผ่าน SQLite sync) — ใช้เฉพาะทดสอบ
- [ ] **6.2** Seed ข้อมูลร้าน/ผู้ใช้/สินค้าใน Firestore (หรือ migration จาก SQLite ขึ้น Firestore) ตาม workflow ที่เลือก
- [ ] **6.3** ทดสอบ flow หลัก: Login → ซิงก์สินค้า → ดูสินค้า/หมวดหมู่ → ขาย → บันทึกบิล → Dashboard

---

## Phase 7 (Optional): Migration & polish

- [ ] **7.1** สคริปต์/ฟังก์ชัน migrate ข้อมูลจาก SQLite ขึ้น Firestore (ถ้าต้องการย้ายข้อมูลเก่า)
- [ ] **7.2** ปิดหรือซ่อน seed แบบ SQLite เมื่อใช้ Firebase
- [ ] **7.3** Error handling + offline/retry — ซิงก์สินค้ามี retry แบบ “ครั้งถัดไป”; ยังไม่มี sync แยกสำหรับ members / categories / sales / loyalty (มีคอลัมน์ `remote_id` / `sync_status` ใน DB แล้ว)

---

## Quick reference

| สิ่งที่ทำแล้ว | ไฟล์/คำสั่ง |
|---------------|-------------|
| โครงสร้าง Firestore paths | `lib/core/firebase/firestore_paths.dart` |
| Config สลับ SQLite / Firestore ตรง | `lib/core/config/app_data_source.dart` |
| Sync สินค้า (offline-first) | `lib/core/sync/sync_manager.dart`, `product_sync_service.dart` |
| Initialize Firebase (เมื่อ useFirebase) | `lib/core/firebase/firebase_app.dart` |
| ออกแบบโครงสร้าง + rules | `docs/firebase_design.md` |

เมื่อทำครบ Phase 1–2 จะได้แอปที่ยังใช้ SQLite แต่มี Firebase init พร้อม แล้วค่อยทำ Phase 3 เป็นต้นไปเพื่อเชื่อม Auth และข้อมูลจริงกับ Firebase
