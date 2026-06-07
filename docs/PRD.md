# Product Requirements Document

## Level Zero — Gamified Self-Development App

### 1. Product Overview

**Level Zero** adalah aplikasi mobile/web yang mengubah pengembangan diri menjadi sistem leveling. Pengguna memilih tujuan hidup, menerima quest harian, menyelesaikan aksi nyata, mendapatkan XP, meningkatkan stats, naik rank, dan menyelesaikan weekly boss challenge.

Produk ini dirancang untuk membuat self-improvement terasa lebih menyenangkan, emosional, dan konsisten.

### 2. Product Goals

1. Membantu user membangun rutinitas pengembangan diri.
2. Membuat habit tracking terasa seperti progression game.
3. Meningkatkan konsistensi user melalui XP, rank, dan reward.
4. Membantu user memahami perkembangan dirinya secara visual.
5. Memberikan pengalaman “real-life character growth”.

### 3. Non-Goals

1. Tidak menjadi game murni.
2. Tidak menggantikan terapi, konseling, atau advice medis.
3. Tidak meniru IP Solo Leveling.
4. Tidak membangun social network penuh pada MVP.
5. Tidak membuat sistem battle kompleks di versi awal.

### 4. Core Product Loop

1. User memilih goal.
2. Sistem memberikan daily quest.
3. User melakukan aktivitas nyata.
4. User menandai quest selesai.
5. User bisa mengunggah proof.
6. User mendapatkan XP dan stat growth.
7. User naik level/rank.
8. User membuka quest baru.
9. User menghadapi weekly boss challenge.
10. User melihat progress melalui profile card.

### 5. User Personas

#### Persona 1 — “The Lost Student”

* Usia: 18–23
* Masalah: hidup tidak terstruktur, sering menunda tugas, ingin berubah tapi bingung mulai dari mana.
* Need: quest sederhana, reminder, visual progress.
* Motivation: ingin merasa hidupnya bergerak maju.

#### Persona 2 — “The Beginner Builder”

* Usia: 20–28
* Masalah: ingin membangun skill coding/design/business tapi tidak konsisten.
* Need: challenge mingguan berbasis output.
* Motivation: ingin punya portfolio dan skill nyata.

#### Persona 3 — “The Gym Starter”

* Usia: 18–28
* Masalah: baru mulai olahraga, susah disiplin.
* Need: fitness quest, streak, proof photo, progression.
* Motivation: ingin tubuh lebih bagus dan percaya diri.

### 6. Information Architecture

#### Main Navigation

1. Dashboard
2. Quest
3. Boss
4. Progress
5. Profile
6. Settings

### 7. Feature Requirements

---

## Feature 1: Authentication

### Description

User dapat membuat akun, login, logout, dan menyimpan progress.

### Requirements

| ID           | Requirement                                    | Priority    |
| ------------ | ---------------------------------------------- | ----------- |
| PRD-AUTH-001 | User dapat register menggunakan email/password | Must Have   |
| PRD-AUTH-002 | User dapat login                               | Must Have   |
| PRD-AUTH-003 | User dapat logout                              | Must Have   |
| PRD-AUTH-004 | User dapat reset password                      | Should Have |
| PRD-AUTH-005 | User dapat login via Google/Apple              | Could Have  |

### Acceptance Criteria

* User dapat membuat akun baru.
* User dapat masuk ke dashboard setelah login.
* Progress user tersimpan per akun.

---

## Feature 2: Onboarding

### Description

User diarahkan untuk melakukan registrasi, memilih goal, kelas karakter, mengisi data fisik, mengunggah foto selfie, dan men-generate avatar RPG pertama mereka yang berbasis AI.

### Onboarding Steps

1. Welcome screen.
2. Pilih main goal.
3. Pilih life class.
4. Input data fisik (Berat badan & Tinggi badan).
5. Upload foto selfie wajah.
6. Pemicu AI Avatar Generation (mengolah foto selfie menjadi avatar RPG level 1).
7. Generate starter quests.
8. Masuk dashboard.

### Main Goal Options

* Build Body
* Build Skill
* Build Mind
* Build Money
* Build Confidence
* Build Discipline

### Life Class Options

| Class      | Focus                                         |
| ---------- | --------------------------------------------- |
| Warrior    | Fitness, discipline, physical strength        |
| Scholar    | Study, reading, learning                      |
| Builder    | Coding, design, business, portfolio           |
| Monk       | Mental health, mindfulness, emotional control |
| Strategist | Money, planning, career                       |

### Requirements

| ID          | Requirement                                           | Priority    |
| ----------- | ----------------------------------------------------- | ----------- |
| PRD-ONB-001 | User dapat memilih satu atau lebih goal               | Must Have   |
| PRD-ONB-002 | User dapat memilih life class                         | Must Have   |
| PRD-ONB-003 | User dapat memasukkan berat badan (kg) & tinggi (cm)  | Must Have   |
| PRD-ONB-004 | User dapat mengambil/mengunggah foto selfie wajah     | Must Have   |
| PRD-ONB-005 | Sistem men-generate RPG Avatar berbasis foto selfie    | Must Have   |
| PRD-ONB-006 | User dapat memilih intensity ringan/sedang/berat      | Must Have   |
| PRD-ONB-007 | Sistem membuat starter quest berdasarkan pilihan user | Must Have   |
| PRD-ONB-008 | User dapat mengubah goal setelah onboarding           | Should Have |

---

## Feature 3: Dashboard

### Description

Dashboard adalah halaman utama yang menampilkan status user hari ini.

### Components

* Rank user
* Level user
* XP progress bar
* Daily quest list
* Current streak
* Stat summary
* Weekly boss progress
* Mentor message

### Requirements

| ID           | Requirement                      | Priority    |
| ------------ | -------------------------------- | ----------- |
| PRD-DASH-001 | Menampilkan rank dan level user  | Must Have   |
| PRD-DASH-002 | Menampilkan XP progress          | Must Have   |
| PRD-DASH-003 | Menampilkan quest hari ini       | Must Have   |
| PRD-DASH-004 | Menampilkan progress weekly boss | Must Have   |
| PRD-DASH-005 | Menampilkan pesan motivasi       | Should Have |

---

## Feature 4: Quest System

### Description

Quest adalah tugas pengembangan diri yang harus diselesaikan user.

### Quest Types

| Type           | Example                         |
| -------------- | ------------------------------- |
| Daily Quest    | Workout 20 menit                |
| Weekly Quest   | Selesaikan 3 sesi belajar       |
| Boss Quest     | Publish 1 mini project          |
| Recovery Quest | Mulai lagi dengan 1 quest kecil |
| Proof Quest    | Upload bukti aktivitas          |

### Quest Difficulty

* E Rank: sangat mudah
* D Rank: mudah
* C Rank: sedang
* B Rank: sulit
* A Rank: sangat sulit
* S Rank: milestone besar

### Requirements

| ID            | Requirement                                     | Priority    |
| ------------- | ----------------------------------------------- | ----------- |
| PRD-QUEST-001 | Sistem memberikan 3 daily quest per hari        | Must Have   |
| PRD-QUEST-002 | User dapat menyelesaikan quest                  | Must Have   |
| PRD-QUEST-003 | User mendapatkan XP setelah menyelesaikan quest | Must Have   |
| PRD-QUEST-004 | Quest memiliki difficulty                       | Must Have   |
| PRD-QUEST-005 | Quest terhubung dengan stat tertentu            | Must Have   |
| PRD-QUEST-006 | User dapat skip quest dengan alasan             | Should Have |
| PRD-QUEST-007 | User dapat membuat custom quest                 | Should Have |
| PRD-QUEST-008 | Sistem dapat generate quest via AI              | Could Have  |

### Quest Example

```text
Quest: Complete 20-minute workout
Difficulty: E
Stat: Strength + Discipline
XP Reward: 50 XP
Proof: Optional
```

---

## Feature 5: XP, Level, Stats, and Rank

### Description

Setiap aktivitas user menghasilkan XP dan meningkatkan stats.

### Stats

| Stat         | Meaning                              |
| ------------ | ------------------------------------ |
| Strength     | Aktivitas fisik                      |
| Intelligence | Belajar dan skill                    |
| Discipline   | Konsistensi                          |
| Charisma     | Sosial dan komunikasi                |
| Wealth       | Finansial dan karier                 |
| Mind         | Mental clarity dan emotional control |

### Rank System

| Rank   | Level Range |
| ------ | ----------- |
| E Rank | Level 1–10  |
| D Rank | Level 11–20 |
| C Rank | Level 21–35 |
| B Rank | Level 36–50 |
| A Rank | Level 51–75 |
| S Rank | Level 76+   |

### Requirements

| ID           | Requirement                              | Priority    |
| ------------ | ---------------------------------------- | ----------- |
| PRD-PROG-001 | User memiliki XP total                   | Must Have   |
| PRD-PROG-002 | User memiliki level                      | Must Have   |
| PRD-PROG-003 | User memiliki rank                       | Must Have   |
| PRD-PROG-004 | User memiliki stat growth                | Must Have   |
| PRD-PROG-005 | XP reward berbeda berdasarkan difficulty | Must Have   |
| PRD-PROG-006 | Proof dapat memberi XP bonus             | Should Have |
| PRD-PROG-007 | User mendapatkan title setelah milestone | Could Have  |

---

## Feature 6: Weekly Boss Challenge

### Description

Weekly boss adalah tantangan mingguan yang lebih besar dari daily quest. Tujuannya adalah membuat user punya milestone nyata.

### Examples

* Complete 3 workout sessions this week.
* Publish 1 coding project.
* Finish 5 study sessions.
* Save Rp100.000 this week.
* Record 1 public speaking practice.

### Requirements

| ID           | Requirement                                       | Priority    |
| ------------ | ------------------------------------------------- | ----------- |
| PRD-BOSS-001 | Sistem membuat 1 weekly boss per minggu           | Must Have   |
| PRD-BOSS-002 | Weekly boss disesuaikan dengan goal user          | Must Have   |
| PRD-BOSS-003 | User mendapatkan XP besar saat boss selesai       | Must Have   |
| PRD-BOSS-004 | User mendapatkan badge/title setelah boss selesai | Should Have |
| PRD-BOSS-005 | User dapat mengganti weekly boss maksimal 1 kali  | Should Have |

---

## Feature 7: Proof Submission

### Description

User dapat mengunggah bukti aktivitas untuk mendapatkan XP bonus.

### Proof Types

* Foto
* Screenshot
* Text note
* Link
* Checklist

### Requirements

| ID            | Requirement                         | Priority    |
| ------------- | ----------------------------------- | ----------- |
| PRD-PROOF-001 | User dapat submit proof untuk quest | Should Have |
| PRD-PROOF-002 | Proof tersimpan di activity history | Should Have |
| PRD-PROOF-003 | Proof memberikan XP bonus           | Should Have |
| PRD-PROOF-004 | AI dapat mengevaluasi proof         | Could Have  |

---

## Feature 8: Recovery System

### Description

Ketika user gagal streak atau tidak aktif, app tidak menghukum secara berlebihan. App memberikan recovery quest agar user kembali.

### Requirements

| ID          | Requirement                                              | Priority    |
| ----------- | -------------------------------------------------------- | ----------- |
| PRD-REC-001 | Sistem mendeteksi user tidak aktif                       | Must Have   |
| PRD-REC-002 | Sistem memberikan recovery quest ringan                  | Should Have |
| PRD-REC-003 | User dapat melanjutkan progress tanpa merasa gagal total | Should Have |
| PRD-REC-004 | Sistem memberi pesan yang supportive                     | Should Have |

---

## Feature 9: Profile Card & RPG Status Screen

### Description

Profile card adalah kartu visual bergaya kartu karakter RPG yang dapat dibagikan oleh user, menampilkan Rank badge, Level, XP bar, Stat Radar Chart, dan **AI Avatar** hasil evolusi terbaru user.

### Requirements

| ID              | Requirement                                                              | Priority    |
| --------------- | ------------------------------------------------------------------------ | ----------- |
| PRD-PROFILE-001 | User dapat melihat profil menu bergaya RPG (Status HUD)                  | Must Have   |
| PRD-PROFILE-002 | Dashboard menampilkan AI Avatar ter-update dan grafik Stat Radar Chart   | Must Have   |
| PRD-PROFILE-003 | User dapat memicu render Profile Card menjadi File Image via iOS         | Should Have |
| PRD-PROFILE-004 | User dapat membagikan (share) image hasil render ke media sosial         | Should Have |
| PRD-PROFILE-005 | User dapat melihat riwayat Trophy/Badge hasil boss fight di profil       | Should Have |

---

## Feature 10: Notification

### Description

Sistem mengirim reminder untuk membantu user menyelesaikan quest.

### Notification Types

* Morning quest reminder.
* Evening incomplete quest reminder.
* Weekly boss reminder.
* Comeback message.
* Rank up message.

### Requirements

| ID            | Requirement                        | Priority    |
| ------------- | ---------------------------------- | ----------- |
| PRD-NOTIF-001 | User menerima reminder daily quest | Must Have   |
| PRD-NOTIF-002 | User dapat mengatur jam reminder   | Should Have |
| PRD-NOTIF-003 | User menerima notifikasi rank up   | Should Have |
| PRD-NOTIF-004 | User dapat mematikan notifikasi    | Must Have   |

### Example Notification Copy

```text
Your daily quests are waiting. Small actions, real XP.
```

```text
Boss challenge ends tonight. Finish strong.
```

---

## Feature 11: In-App Book Reader & Focus Timer

### Description

User dapat memilih dan membaca buku-buku pengembangan diri secara langsung di dalam aplikasi. Saat membaca, terdapat 10-minute focus timer yang melacak durasi membaca dengan sensor anti-idle berbasis page-turn detection. Setelah selesai, user menulis refleksi singkat untuk mengklaim reward XP.

### Requirements

| ID             | Requirement                                                                    | Priority    |
| -------------- | ------------------------------------------------------------------------------ | ----------- |
| PRD-READ-001   | User dapat memilih buku dari pustaka (Library) aplikasi                        | Must Have   |
| PRD-READ-002   | Aplikasi dapat me-render teks/halaman buku dengan rapi (custom reader UI)      | Must Have   |
| PRD-READ-003   | Layar baca menampilkan focus timer hitung mundur 10 menit                      | Must Have   |
| PRD-READ-004   | Timer akan otomatis terjeda jika tidak ada gerakan membalik halaman (3 menit)   | Must Have   |
| PRD-READ-005   | Setelah 10 menit selesai, aplikasi memunculkan form input refleksi singkat     | Must Have   |
| PRD-READ-006   | User mendapatkan +25 XP setelah menyubmit kalimat refleksi                     | Must Have   |
| PRD-READ-007   | Hasil refleksi disimpan di riwayat aktivitas user                              | Should Have |

---

## 8. Non-Functional Requirements

### Performance

* Dashboard load time maksimal 2 detik.
* Quest completion harus terasa instan.
* App harus tetap nyaman di device low-end.

### Security

* Password harus di-hash.
* User data harus private by default.
* Proof upload harus dibatasi ukuran file.
* Auth token harus aman.

### Privacy

* User dapat menghapus akun.
* User dapat menghapus proof.
* Data self-improvement tidak boleh dibagikan tanpa consent.
* Profile card hanya shareable jika user memilih share.

### Scalability

* Quest system harus modular.
* Life class dan stat dapat ditambah tanpa mengubah core architecture.
* Sistem harus mendukung AI-generated quest di masa depan.

### Accessibility

* Kontras teks harus baik.
* Font mudah dibaca.
* Button harus cukup besar.
* App tidak boleh hanya mengandalkan warna untuk membedakan status.

### Platform

MVP Spesifikasi:

* **Frontend**: iOS Native App (SwiftUI).
* **Backend**: Supabase (Database PostgreSQL, Supabase Auth, Real-time API).
* **Storage**: Supabase Storage (untuk foto selfie onboarding dan bukti/proof quest).
* **AI Engine**: Supabase Edge Functions + AI Image Generation API (Replicate SDXL/InstantID) untuk avatar awal dan regenerasi evolusi avatar saat rank up.

### 9. Analytics Events

| Event                    | Trigger                       |
| ------------------------ | ----------------------------- |
| user_registered          | User berhasil register        |
| onboarding_completed     | User menyelesaikan onboarding |
| quest_generated          | Quest dibuat                  |
| quest_completed          | User menyelesaikan quest      |
| proof_uploaded           | User upload proof             |
| level_up                 | User naik level               |
| rank_up                  | User naik rank                |
| weekly_boss_started      | Weekly boss aktif             |
| weekly_boss_completed    | Weekly boss selesai           |
| profile_card_shared      | User share profile card       |
| user_inactive_detected   | User tidak aktif              |
| recovery_quest_completed | User kembali setelah gagal    |

### 10. MVP Release Criteria

MVP siap dirilis jika:

* User bisa daftar/login.
* User bisa menyelesaikan onboarding.
* Sistem bisa membuat daily quest.
* User bisa complete quest.
* XP, level, rank, dan stats berubah sesuai quest.
* Weekly boss tersedia.
* Dashboard progress terlihat jelas.
* Data user tersimpan.
* Tidak ada bug kritis di core loop.
