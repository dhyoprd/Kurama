# Wireframe, Mockup, & Prototype Desain — Level Zero iOS

Dokumen ini menjelaskan struktur visual (wireframe), panduan desain (mockup), dan alur interaksi (prototype) untuk aplikasi iOS Native **Level Zero** menggunakan SwiftUI.

---

## 1. Panduan Desain Visual (Mockup Guidelines)

Aplikasi ini menggunakan tema **Dark-RPG / Cyberpunk** yang intens dan imersif, dirancang untuk memberikan *"main character energy"* kepada pengguna.

### A. Palet Warna (Cyberpunk Neon Palette)
*   **Background Utama**: `#0B0C10` (Deep Space Black - Hitam Pekat)
*   **Card / Containers**: `#1F2833` (Dark Slate Grey - Abu-abu gelap)
*   **Warna Aksen 1 (Primary/Level/Misi)**: `#66FCF1` (Neon Cyan - Biru muda berpendar)
*   **Warna Aksen 2 (Boss/Rank S)**: `#8A2BE2` (Purple Glow - Ungu pekat neon)
*   **Warna Aksen 3 (Streak/Warning)**: `#FFD700` (Gold Flame - Kuning emas api)
*   **Teks Utama**: `#FFFFFF` (Solid White)
*   **Teks Sekunder**: `#C5C6C7` (Light Ash Grey)

### B. Tipografi (Typography)
*   **Title/Header Misi/Level**: Font bertema gaming/futuristik (contoh: *Outfit* atau *Impact* dengan efek tracking agak lebar).
*   **Teks Deskripsi/Buku**: Font serif/sans-serif bersih (*Inter* atau *Georgia* untuk mode baca buku) agar tidak melelahkan mata saat dibaca 10 menit.

### C. Efek & Ornamen UI
*   **Neon Outer Glow**: Batas kartu (borders) memiliki efek blur pendaran neon (cyan atau purple) yang intensitasnya disesuaikan dengan difficulty quest/rank.
*   **Glassmorphism**: Beberapa popup modal menggunakan efek blur latar belakang (*SwiftUI Material Blur*) untuk memberikan kesan kedalaman layar.
*   **Haptic Feedback**: Getaran taktil yang presisi saat membalik halaman buku, menyelesaikan quest (*success haptic*), atau gagal/inaktif.

---

## 2. Wireframe Struktur Layar (Layouts)

Berikut adalah wireframe layout halaman-halaman kunci menggunakan diagram kotak untuk menggambarkan tata letak elemen di layar iPhone.

### Layar 1: Onboarding & Selfie Upload (Layout)
```text
+------------------------------------------+
|  [Back]                           (1/4)  |
|                                          |
|            CREATE YOUR AVATAR            |
|       "Upload your face to begin"        |
|                                          |
|                 +------+                 |
|                 | Selfie|                 |
|                 | Camera|                 |
|                 |  Icon |                 |
|                 +------+                 |
|             [ Upload Photo ]             |
|                                          |
|  Physical Info:                          |
|  [ Height (cm) ]      [ Weight (kg) ]    |
|                                          |
|  Life Class Selection:                   |
|  [ Warrior ] [ Builder ] [ Scholar ]...  |
|                                          |
|                                          |
|  [           GENERATE AVATAR           ] |
+------------------------------------------+
```

### Layar 2: Character Dashboard / Status HUD (Layout)
```text
+------------------------------------------+
|  [Fire] 14 Days Streak         [Settings]|
|                                          |
|  +------------------------------------+  |
|  |           AI AVATAR CARD           |  |
|  |            (FULL-BODY)             |  |
|  |                                    |  |
|  |     [ "Keep moving forward!" ]     |  |
|  |       (Bubble chat on tap)         |  |
|  +------------------------------------+  |
|  NAME: JinWoo  |  LVL: 14  | D-Rank      |
|  CLASS: Warrior (Parallax/Particles UI)  |
|  [========== XP: 1420 / 1500 ==========] |
|                                          |
|            STAT RADAR CHART              |
|                 /\ STR                   |
|            MND /  \ INT                  |
|               |    |                     |
|            WEA \  / CHA                  |
|                 \/ DIS                   |
|                                          |
|  ACTIVE QUESTS                           |
|  +-------------------------------------+ |
|  | Quest 1: Workout 20m (Swipe to Comp)| |
|  +-------------------------------------+ |
|  | Quest 2: Focus Read 10m (Swipe to C)| |
|  +-------------------------------------+ |
+------------------------------------------+
```

### Layar 3: In-App E-Reader & Focus Timer (Layout)
```text
+------------------------------------------+
|  [Close]    ATOMIC HABITS    [Timer 09:58]|
|                                          |
|  Chapter 1: The Surprising Power of      |
|  Tiny Habits...                          |
|                                          |
|  Success is the product of daily habits— |
|  not once-in-a-lifetime transformations. |
|                                          |
|  You do not rise to the level of your    |
|  goals. You fall to the level of your    |
|  systems.                                |
|                                          |
|  An atomic habit is a little habit that  |
|  is part of a larger system.             |
|                                          |
|                                          |
|  < Prev Page                      Next > |
|  [======= Page 12 of 320 (8%) =======]   |
+------------------------------------------+
```

---

## 3. Prototype Alur Interaksi (User Flow)

Diagram di bawah ini menggambarkan alur interaksi terperinci dari proses onboarding, evolusi avatar, hingga pemicu sensor keaktifan membaca buku 10 menit.

```mermaid
sequenceDiagram
    autonumber
    actor User
    participant App as SwiftUI Client (iOS)
    participant DB as Supabase DB & Storage
    participant AI as Supabase Edge Function (AI Gen)

    %% ONBOARDING FLOW
    Note over User, AI: 1. Alur Pembuatan Avatar Awal (Onboarding)
    User->>App: Input Tinggi, Berat & Upload Foto Selfie
    App->>DB: Simpan Foto ke Storage bucket 'selfies'
    App->>AI: Panggil API Generator (Selfie, Class, Height/Weight)
    Note over AI: AI memproses wajah + prompt Full-Body Novice Level 1
    AI-->>App: Return URL Full-Body Avatar Level 1
    App->>DB: Update 'avatar_url' di tabel profiles
    App->>User: Tampilkan Full-Body Avatar Level 1 dengan particle effects

    %% INTERACTIVE AVATAR FEATURES
    Note over User, App: 2. Alur Interaksi Avatar di Dashboard
    User->>App: Tap pada bagian tubuh Avatar
    App->>User: Tampilkan bubble chat berisi saran/motivasi sesuai stat terlemah
    User->>App: Miringkan iPhone (Gyroscope sensor trigger)
    App->>App: Update sudut pandang 3D parallax background avatar secara real-time

    %% FOCUS READING FLOW WITH ANTI-IDLE
    Note over User, AI: 3. Alur Membaca Buku 10 Menit & Rule Anti-Idle
    User->>App: Buka menu Library & Pilih Buku
    User->>App: Tekan "Start Reading Session"
    App->>App: Jalankan Mode Layar Penuh & 10-Minute Focus Timer
    loop Deteksi Aktivitas Membaca (Setiap 3 Menit)
        alt User aktif membalik halaman (Swipe / Page Turn)
            App->>App: Lanjutkan hitung mundur timer
        else User diam (Tidak membalik halaman > 180 detik)
            App->>App: Jeda timer & Tampilkan pop-up "Are you still reading?"
            User->>App: Tap layar untuk melanjutkan membaca
            App->>App: Lanjutkan hitung mundur timer
        end
    end
    App->>App: Timer Selesai (10 Menit Tercapai) -> Bunyikan Haptic & Tampilkan Modal Refleksi
    User->>App: Tulis minimal 1 kalimat refleksi (Takeaway)
    App->>DB: Simpan data ke tabel user_reading_sessions (Takeaway & XP +25)
    DB-->>App: Sukses simpan
    App->>User: Animasi Klaim XP + Peningkatan Stat Intelligence/Mind

    %% AVATAR EVOLUTION ON RANK UP
    Note over User, AI: 4. Alur Rank-Up & Evolusi Avatar AI
    Note over App: Level bertambah & Memicu Rank Up (E -> D)
    App->>DB: Cek status stat tertinggi (misal: Strength)
    App->>AI: Panggil API Re-generation (Selfie + Prompt Warrior Iron Armor + Muscular Build)
    Note over AI: AI merender ulang full-body user dengan armor Warrior Rank D tegap
    AI-->>App: Return URL Evolved Full-Body Avatar baru
    App->>DB: Update 'avatar_url' terbaru
    App->>User: Animasi Rank Up + Reveal Evolved Avatar Baru dengan Neon Border!
```
