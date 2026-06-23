# Who is Impostor

Pass & Play mobil parti oyunu — tek telefondan elden ele oynanır.

## Kurulum

```bash
flutter pub get
flutter run
```

## Renk Paleti

| Katman | Renk | Hex | Kullanım |
|--------|------|-----|----------|
| **Void Black** | ![#0A0A0F](https://via.placeholder.com/15/0A0A0F/0A0A0F) | `#0A0A0F` | En derin arka plan |
| **Abyss** | ![#12121A](https://via.placeholder.com/15/12121A/12121A) | `#12121A` | Scaffold / ana yüzey |
| **Surface** | ![#1A1A26](https://via.placeholder.com/15/1A1A26/1A1A26) | `#1A1A26` | Kartlar, paneller |
| **Mystic Purple** | ![#9B5DE5](https://via.placeholder.com/15/9B5DE5/9B5DE5) | `#9B5DE5` | Birincil CTA, marka glow |
| **Neon Green** | ![#00F5A0](https://via.placeholder.com/15/00F5A0/00F5A0) | `#00F5A0` | Vurgu, Pass & Play badge |
| **Text Primary** | ![#F0F0F5](https://via.placeholder.com/15/F0F0F5/F0F0F5) | `#F0F0F5` | Başlıklar |
| **Text Secondary** | ![#9898B0](https://via.placeholder.com/15/9898B0/9898B0) | `#9898B0` | Alt metinler |

## Proje Yapısı

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart   # Renk paleti & gradyanlar
│   │   └── app_theme.dart    # Material 3 dark theme
│   └── widgets/
│       └── premium_widgets.dart  # GlowButton, PremiumCard
├── features/
│   └── home/
│       └── home_screen.dart  # Ana ekran
└── main.dart
```

## Teknoloji

- **Flutter** (Material 3)
- **Google Fonts** (Outfit)
