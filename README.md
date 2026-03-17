# 🌍 Petualang Siaga Bumi

Aplikasi edukasi berbasis **gamifikasi** untuk pembelajaran mitigasi bencana secara interaktif dan menyenangkan.

---

## 🎮 Preview

Aplikasi ini membawa siswa dalam petualangan belajar melalui beberapa level (POS), mulai dari materi hingga simulasi dan kuis.

---

## ✨ Fitur Utama

* 📚 **POS 1 – Lesson**

  * Pembelajaran materi dasar bencana
  * Sistem unlock + XP reward

* 🎯 **POS 2 – Drag & Drop**

  * Interaksi mencocokkan objek
  * Harus menyelesaikan semua target

* 🧠 **POS 3 – Matching**

  * Cocokkan bencana dengan dampaknya

* 🎭 **POS 4 – Decision System**

  * Simulasi pengambilan keputusan
  * Pilihan mempengaruhi hasil

* 📝 **POS 5 – Quiz**

  * Soal acak
  * Minimal nilai **75%**
  * 🎓 Sertifikat Digital

---

## 🎮 Gamification System

| Element   | Description              |
| --------- | ------------------------ |
| ❤️ Hearts | Nyawa pemain             |
| ⭐ XP      | Experience point         |
| 🏆 Level  | Progress permainan       |
| 🔓 Unlock | Membuka level berikutnya |

---

## 🧠 Mekanisme Game

* ✔ Jawaban benar → +XP + sound + animasi
* ❌ Jawaban salah → -1 heart
* 💀 Heart habis → kembali ke Map
* 🎯 Level terbuka setelah menyelesaikan stage

---

## 🏗️ Tech Stack

* **Flutter**
* **Riverpod (State Management)**
* **Just Audio (Sound)**
* **Flutter Animate**
* **Custom Painter (Map Path)**

---

## 📁 Struktur Project

```bash
lib/
│
├── core/
│   ├── features/
│   │   ├── home_map/
│   │   ├── lesson/
│   │   ├── quiz/
│   │   └── result/
│   │
│   ├── presentation/
│   │   └── widgets/
│   │
│   └── utils/
│       └── game_provider.dart
│
├── data/
│   ├── models/
│   └── repositories/
│
└── main.dart
```

---

## 🔄 Flow Aplikasi

```text
Map → POS 1 → POS 2 → POS 3 → POS 4 → POS 5 → Sertifikat
```

---

## 🔊 Audio System

* click.mp3 → klik tombol
* correct.mp3 → jawaban benar
* wrong.mp3 → jawaban salah

---

## 🚀 Cara Menjalankan

```bash
git clone https://github.com/username/petualangansiagabumi.git
cd petualangansiagabumi
flutter pub get
flutter run
```

---

## 📸 Screenshot

<p align="center">
  <img src="assets/screenshot/home.jpg" width="250"/>
  <img src="assets/screenshot/lesson.jpg" width="250"/>
  <img src="assets/screenshot/dragdrop.jpg" width="250"/>
</p>

<p align="center">
  <img src="assets/screenshot/matching.jpg" width="250"/>
  <img src="assets/screenshot/decision.jpg" width="250"/>
  <img src="assets/screenshot/quiz.jpg" width="250"/>
</p>

<p align="center">
  <img src="assets/screenshot/result.jpg" width="250"/>
</p>

## 🎓 Output

Jika pemain lulus quiz:

🏆 **Sertifikat Digital**
"Siswa Tangguh Bencana"

---

## 🧑‍💻 Developer

**Ramzi Syuhada**
Flutter Developer | VR/AR Enthusiast

---

## 📌 Future Development

* 🌐 Leaderboard online
* 🧍 Avatar customization
* 📊 Progress analytics
* 🤖 AI adaptive learning
* 🥽 Integrasi VR/AR

---

## ⭐ Support

Kalau project ini membantu:

👉 Star repo ini ⭐
👉 Fork & contribute 🚀

---
