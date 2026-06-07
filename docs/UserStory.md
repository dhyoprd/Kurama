# User Stories and Use Cases

## Level Zero — Gamified Self-Development App

---

# Part 1 — User Stories

## Epic 1: Authentication

### US-001 — Register Account

**As a new user,**
I want to create an account,
so that my progress can be saved.

**Acceptance Criteria**

* Given user membuka halaman register, when user mengisi email dan password valid, then akun berhasil dibuat.
* Given email sudah digunakan, when user mencoba register, then sistem menampilkan error.
* Given register berhasil, when user selesai, then user diarahkan ke onboarding.

---

### US-002 — Login Account

**As a returning user,**
I want to login,
so that I can continue my progression.

**Acceptance Criteria**

* Given user memiliki akun, when user memasukkan credential valid, then user masuk ke dashboard.
* Given credential salah, when user login, then sistem menampilkan pesan error.
* Given user sudah login, when membuka app, then user tetap berada dalam session aktif.

---

## Epic 2: Onboarding

### US-003 — Choose Main Goal

**As a new user,**
I want to choose my main self-development goal,
so that the app can personalize my quests.

**Acceptance Criteria**

* Given user berada di onboarding, when user memilih goal, then sistem menyimpan goal tersebut.
* Given user belum memilih goal, when user menekan continue, then sistem meminta user memilih minimal satu goal.
* Given user memilih goal, then rekomendasi life class disesuaikan.

---

### US-004 — Choose Life Class

**As a new user,**
I want to choose a life class,
so that my self-development journey feels more personal.

**Acceptance Criteria**

* Given user berada di halaman class selection, when user memilih class, then class tersimpan di profile.
* Given user memilih Warrior, then quest awal fokus pada fitness dan discipline.
* Given user memilih Builder, then quest awal fokus pada skill dan output.

---

### US-005 — Set Quest Intensity

**As a new user,**
I want to choose quest intensity,
so that the quests match my current lifestyle.

**Acceptance Criteria**

* Given user memilih easy, then sistem memberikan quest ringan.
* Given user memilih normal, then sistem memberikan quest sedang.
* Given user memilih hard, then sistem memberikan quest yang lebih menantang.
* Given intensity sudah dipilih, then user diarahkan ke langkah berikutnya.

---

### US-005a — Enter Physical Attributes

**As a new user,**
I want to enter my height and weight,
so that I can track my physical stats alongside my character growth.

**Acceptance Criteria**

* Given user berada di halaman data fisik, when user mengisi tinggi (cm) dan berat (kg) yang valid, then data tersimpan di profil.
* Given user mengosongkan kolom input, when menekan next, then sistem memunculkan warning untuk mengisi data.

---

### US-005b — Upload Selfie for AI Avatar

**As a new user,**
I want to upload a selfie photo of my face,
so that the app can generate my initial Level 1 RPG Character Avatar.

**Acceptance Criteria**

* Given user berada di halaman selfie upload, when user mengambil foto dari kamera atau galeri, then foto diunggah ke storage.
* Given foto berhasil diunggah, when sistem memicu AI generator, then avatar RPG Level 1 yang mirip dengan wajah user di-generate dan disimpan ke profil.
* Given avatar selesai dibuat, then user diarahkan ke dashboard.

---

## Epic 3: Daily Quest

### US-006 — View Daily Quest

**As a user,**
I want to see my daily quests,
so that I know what actions to take today.

**Acceptance Criteria**

* Given user membuka dashboard, then sistem menampilkan quest hari ini.
* Given user belum punya quest hari ini, then sistem membuat quest baru.
* Given quest sudah dibuat, then quest tidak berubah tanpa aksi user.

---

### US-007 — Complete Quest

**As a user,**
I want to mark a quest as completed,
so that I can earn XP and progress.

**Acceptance Criteria**

* Given quest belum selesai, when user menekan complete, then quest berubah menjadi completed.
* Given quest selesai, then user mendapat XP.
* Given XP cukup, then user naik level.
* Given quest sudah complete, then user tidak bisa claim XP dua kali.

---

### US-008 — Skip Quest

**As a user,**
I want to skip a quest,
so that I can adjust when the quest is not relevant today.

**Acceptance Criteria**

* Given user memilih skip, then sistem meminta alasan.
* Given quest di-skip, then user tidak mendapat XP.
* Given user skip terlalu sering, then sistem memberi saran menurunkan intensity.
* Given user skip, then quest tercatat di history.

---

## Epic 4: XP, Stats, and Rank

### US-009 — Gain XP

**As a user,**
I want to gain XP after completing a quest,
so that I feel rewarded for my effort.

**Acceptance Criteria**

* Given user menyelesaikan quest E-rank, then user mendapat XP kecil.
* Given user menyelesaikan quest difficulty lebih tinggi, then user mendapat XP lebih besar.
* Given user upload proof, then user mendapat XP bonus jika fitur aktif.
* Given XP bertambah, then XP bar ikut berubah.

---

### US-010 — Level Up

**As a user,**
I want to level up,
so that I can see my growth over time.

**Acceptance Criteria**

* Given XP user mencapai threshold, then level user bertambah.
* Given user naik level, then sistem menampilkan level-up feedback.
* Given user naik level, then activity history mencatat perubahan tersebut.

---

### US-011 — Rank Up

**As a user,**
I want to rank up and see my full-body AI avatar evolve,
so that I get a visual sense of my character's growth and stats progression.

**Acceptance Criteria**

* Given user mencapai level tertentu, then rank user bertambah (E -> D -> C -> B -> A -> S).
* Given rank bertambah, then sistem mendeteksi stat tertinggi user dan memicu Supabase Edge Function untuk me-render ulang full-body avatar baru dengan armor/gear yang sesuai.
* Given render selesai, then sistem menampilkan animasi dramatis transisi rank up di iOS.
* Given rank up berhasil, then dashboard memperbarui tampilan full-body avatar baru, warna glowing border, efek partikel, dan chat bubble motivasi baru.
* Given rank up berhasil, then profile card diperbarui secara otomatis.

---

## Epic 5: Weekly Boss

### US-012 — View Weekly Boss

**As a user,**
I want to see my weekly boss challenge,
so that I have a meaningful goal for the week.

**Acceptance Criteria**

* Given minggu baru dimulai, then sistem membuat weekly boss.
* Given user membuka halaman Boss, then weekly boss ditampilkan.
* Given user punya goal Builder, then boss challenge berhubungan dengan output/skill.
* Given user punya goal Warrior, then boss challenge berhubungan dengan fitness.

---

### US-013 — Complete Weekly Boss

**As a user,**
I want to complete my weekly boss,
so that I can earn a bigger reward.

**Acceptance Criteria**

* Given user memenuhi semua syarat boss, when user menyelesaikan boss, then boss status menjadi completed.
* Given boss completed, then user mendapat XP besar.
* Given boss completed, then user mendapat badge/title jika tersedia.
* Given boss sudah selesai, then user tidak bisa claim reward dua kali.

---

## Epic 6: Proof Submission

### US-014 — Upload Proof

**As a user,**
I want to upload proof for completed quests,
so that my progress feels more accountable.

**Acceptance Criteria**

* Given quest mendukung proof, when user upload foto/screenshot/catatan, then proof tersimpan.
* Given file terlalu besar, then sistem menampilkan error.
* Given proof berhasil upload, then proof muncul di activity history.
* Given proof valid, then user bisa menerima XP bonus.

---

## Epic 7: Recovery

### US-015 — Come Back After Missing Quest

**As a user,**
I want to recover after missing my quests,
so that I do not feel like I have failed completely.

**Acceptance Criteria**

* Given user tidak aktif selama 1 hari, then sistem menampilkan recovery message.
* Given user kembali setelah tidak aktif, then sistem memberikan recovery quest ringan.
* Given recovery quest selesai, then user mendapatkan XP kecil.
* Given user menyelesaikan recovery quest, then user diarahkan kembali ke normal quest loop.

---

## Epic 8: Profile Card

### US-016 — View Profile Card

**As a user,**
I want to view my profile card,
so that I can see my rank, stats, and progress.

**Acceptance Criteria**

* Given user membuka profile, then sistem menampilkan rank, level, XP, stats, dan title.
* Given user naik level, then profile card otomatis update.
* Given user menyelesaikan boss, then achievement muncul di profile.

---

### US-017 — Share Profile Card

**As a user,**
I want to share my profile card,
so that I can show my progress to others.

**Acceptance Criteria**

* Given user membuka profile card, when user menekan share, then sistem membuat shareable image/link.
* Given profile card dibagikan, then data sensitif tidak ikut tampil.
* Given user tidak ingin share, then profile tetap private.

---

## Epic 9: Book Reading

### US-018 — Start Book Reading Session

**As a user,**
I want to select a self-improvement book and start a 10-minute focus reading session,
so that I can build a reading habit and gain character growth XP.

**Acceptance Criteria**

* Given user membuka tab Library, when user menekan tombol 'Start Reading' pada salah satu buku, then aplikasi masuk ke mode reading fullscreen dan mendefinisikan focus timer 10 menit.
* Given timer sedang berjalan, when user tidak membalik halaman buku selama > 3 menit, then timer otomatis dijeda (paused) dan muncul pop-up focus check.
* Given user melakukan interaksi swipe/sentuh setelah dijeda, then timer dilanjutkan kembali.

---

### US-019 — Submit Reading Takeaway

**As a user,**
I want to write a short reflection after completing my 10-minute reading session,
so that I can claim my reward XP.

**Acceptance Criteria**

* Given timer 10 menit selesai, then aplikasi memunculkan form input modal untuk menulis refleksi.
* Given user mengetik minimal 1 kalimat takeaway dan menekan submit, then data disimpan ke profil dan user mendapatkan +25 XP.
* Given user menutup modal refleksi tanpa submit, then XP tidak dapat diklaim sampai refleksi dikirim.

---

# Part 2 — Use Case List

| Use Case ID | Use Case Name            | Actor    | Priority    |
| ----------- | ------------------------ | -------- | ----------- |
| UC-001      | Register Account         | New User | Must Have   |
| UC-002      | Complete Onboarding      | New User | Must Have   |
| UC-003      | Generate Daily Quest     | System   | Must Have   |
| UC-004      | Complete Daily Quest     | User     | Must Have   |
| UC-005      | Gain XP and Update Stats | System   | Must Have   |
| UC-006      | Level Up User            | System   | Must Have   |
| UC-007      | Generate Weekly Boss     | System   | Must Have   |
| UC-008      | Complete Weekly Boss     | User     | Must Have   |
| UC-009      | Upload Proof             | User     | Should Have |
| UC-010      | Trigger Recovery Quest   | System   | Should Have |
| UC-011      | View Progress Dashboard  | User     | Must Have   |
| UC-012      | Share Profile Card       | User     | Should Have |
| UC-013      | Send Quest Reminder      | System   | Should Have |
| UC-014      | Change Quest Intensity   | User     | Should Have |
| UC-015      | Read Book with Focus Timer| User    | Must Have   |
| UC-016      | Submit Reading Reflection| User     | Must Have   |

---

# Part 3 — Detailed Use Cases

## UC-001 — Register Account

### Primary Actor

New User

### Goal

User membuat akun untuk menyimpan progress.

### Preconditions

User belum login.

### Main Flow

1. User membuka app.
2. User memilih register.
3. User memasukkan email dan password.
4. Sistem memvalidasi input.
5. Sistem membuat akun.
6. Sistem mengarahkan user ke onboarding.

### Alternative Flow

* Jika email sudah digunakan, sistem menampilkan pesan error.
* Jika password terlalu lemah, sistem meminta user mengganti password.

### Postconditions

Akun user berhasil dibuat.

---

## UC-002 — Complete Onboarding

### Primary Actor

New User

### Goal

User menyelesaikan setup awal agar quest dapat dipersonalisasi.

### Preconditions

User sudah register atau login.

### Main Flow

1. User masuk ke onboarding.
2. User memilih main goal.
3. User memilih life class.
4. User memilih quest intensity.
5. Sistem membuat starter quest.
6. User diarahkan ke dashboard.

### Alternative Flow

* Jika user melewati goal selection, sistem meminta user memilih minimal satu goal.
* Jika user keluar dari onboarding, sistem menyimpan progress onboarding sementara.

### Postconditions

Profile awal user selesai dibuat.

---

## UC-003 — Generate Daily Quest

### Primary Actor

System

### Goal

Sistem membuat quest harian yang sesuai dengan goal user.

### Preconditions

User sudah menyelesaikan onboarding.

### Main Flow

1. Sistem mengecek tanggal hari ini.
2. Sistem mengecek goal, class, intensity, dan progress user.
3. Sistem memilih quest dari quest pool.
4. Sistem menetapkan difficulty dan XP reward.
5. Sistem menampilkan quest di dashboard.

### Alternative Flow

* Jika quest pool kosong, sistem memakai fallback quest.
* Jika user sudah punya quest hari ini, sistem tidak membuat quest baru.

### Postconditions

Daily quest tersedia untuk user.

---

## UC-004 — Complete Daily Quest

### Primary Actor

User

### Goal

User menyelesaikan quest untuk mendapatkan XP.

### Preconditions

User memiliki daily quest aktif.

### Main Flow

1. User membuka dashboard.
2. User memilih quest.
3. User menekan complete.
4. Sistem mengubah status quest menjadi completed.
5. Sistem memberikan XP.
6. Sistem memperbarui stats.
7. Sistem mengecek level up.
8. Sistem menampilkan feedback.

### Alternative Flow

* Jika quest memerlukan proof, user diminta upload proof.
* Jika user membatalkan aksi, quest tetap aktif.
* Jika quest sudah selesai, sistem menolak claim XP kedua.

### Postconditions

Quest selesai dan progress user diperbarui.

---

## UC-005 — Gain XP and Update Stats

### Primary Actor

System

### Goal

Sistem memperbarui XP, level, rank, dan stats user.

### Preconditions

User menyelesaikan quest.

### Main Flow

1. Sistem membaca XP reward quest.
2. Sistem menambahkan XP ke user.
3. Sistem menambahkan stat sesuai kategori quest.
4. Sistem mengecek apakah XP mencapai level threshold.
5. Sistem mengecek apakah user mencapai rank threshold.
6. Sistem menyimpan progress.

### Alternative Flow

* Jika proof tersedia, sistem menambahkan bonus XP.
* Jika terjadi error penyimpanan, sistem menampilkan retry.

### Postconditions

Progress user berhasil diperbarui.

---

## UC-006 — Generate Weekly Boss

### Primary Actor

System

### Goal

Sistem membuat tantangan mingguan yang lebih meaningful.

### Preconditions

User aktif dan sudah menyelesaikan onboarding.

### Main Flow

1. Sistem mengecek awal minggu.
2. Sistem membaca main goal user.
3. Sistem memilih boss challenge dari template.
4. Sistem menetapkan reward besar.
5. Sistem menampilkan boss di halaman Boss.

### Alternative Flow

* Jika user baru join di tengah minggu, sistem membuat starter boss yang lebih ringan.
* Jika user mengganti goal, boss minggu berikutnya menyesuaikan.

### Postconditions

Weekly boss aktif.

---

## UC-007 — Complete Weekly Boss

### Primary Actor

User

### Goal

User menyelesaikan milestone mingguan.

### Preconditions

Weekly boss aktif.

### Main Flow

1. User membuka halaman Boss.
2. User melihat requirements boss.
3. User menyelesaikan requirements.
4. User menekan complete.
5. Sistem memvalidasi progress.
6. Sistem memberikan XP besar.
7. Sistem memberi badge/title jika tersedia.
8. Sistem memperbarui profile card.

### Alternative Flow

* Jika requirements belum terpenuhi, sistem menampilkan progress yang masih kurang.
* Jika weekly boss expired, sistem menandai boss sebagai failed/unfinished.

### Postconditions

Weekly boss selesai dan reward diberikan.

---

## UC-008 — Upload Proof

### Primary Actor

User

### Goal

User menambahkan bukti penyelesaian quest.

### Preconditions

Quest aktif atau baru saja selesai.

### Main Flow

1. User membuka detail quest.
2. User memilih upload proof.
3. User memilih file atau menulis note.
4. Sistem memvalidasi ukuran dan format.
5. Sistem menyimpan proof.
6. Sistem memberi XP bonus jika applicable.

### Alternative Flow

* Jika file gagal upload, sistem menampilkan retry.
* Jika format tidak didukung, sistem menampilkan error.
* Jika user skip proof, quest tetap bisa selesai jika proof optional.

### Postconditions

Proof tersimpan di activity history.

---

## UC-009 — Trigger Recovery Quest

### Primary Actor

System

### Goal

Membantu user kembali setelah tidak aktif.

### Preconditions

User tidak menyelesaikan quest selama periode tertentu.

### Main Flow

1. Sistem mendeteksi user tidak aktif.
2. Sistem menampilkan recovery message.
3. Sistem membuat recovery quest ringan.
4. User menyelesaikan recovery quest.
5. Sistem memberi XP kecil.
6. Sistem mengembalikan user ke normal quest loop.

### Alternative Flow

* Jika user tidak membuka app, sistem mengirim comeback notification.
* Jika user gagal recovery quest, sistem menurunkan difficulty.

### Postconditions

User kembali aktif tanpa merasa gagal total.

---

## UC-010 — Share Profile Card

### Primary Actor

User

### Goal

User membagikan progress dalam bentuk visual.

### Preconditions

User memiliki profile card.

### Main Flow

1. User membuka profile.
2. User memilih share profile card.
3. Sistem membuat image/link.
4. User memilih platform share.
5. Sistem mencatat share event.

### Alternative Flow

* Jika user membatalkan share, tidak ada data yang dibagikan.
* Jika generate image gagal, sistem menampilkan retry.

### Postconditions

Profile card berhasil dibagikan atau siap dibagikan.

---

# Part 4 — MVP User Flow

## First-Time User Flow

1. Open app.
2. Register/login.
3. See welcome message.
4. Choose main goal.
5. Choose life class.
6. Choose quest intensity.
7. Receive first daily quest.
8. Complete first quest.
9. Gain XP.
10. See profile/rank.
11. Return tomorrow.

## Daily Active User Flow

1. Open app.
2. See today’s quest.
3. Complete quest.
4. Upload proof if desired.
5. Gain XP.
6. See XP bar increase.
7. Check weekly boss progress.
8. Close app.

## Weekly Boss Flow

1. User opens Boss page.
2. User sees weekly challenge.
3. User completes required actions during the week.
4. User claims boss reward.
5. User receives XP, badge, and progress update.

## Recovery Flow

1. User misses quest.
2. App detects inactivity.
3. App gives supportive comeback message.
4. User receives simple recovery quest.
5. User completes small action.
6. User returns to normal loop.

---

# Part 5 — Edge Cases

| Scenario                    | Expected Behavior                               |
| --------------------------- | ----------------------------------------------- |
| User completes quest twice  | Sistem mencegah double XP                       |
| User changes goal           | Quest berikutnya menyesuaikan                   |
| User misses several days    | Sistem memberi recovery path                    |
| User deletes proof          | Proof hilang, tapi completion history tetap ada |
| User has no internet        | App menampilkan cached data jika memungkinkan   |
| Quest generation fails      | Sistem memakai fallback quest                   |
| User skips too many quests  | Sistem menyarankan intensity lebih rendah       |
| User uploads large file     | Sistem menolak dan memberi pesan error          |
| User wants privacy          | Profile card tidak dibagikan otomatis           |
| User reaches rank threshold | Sistem melakukan rank up otomatis               |
