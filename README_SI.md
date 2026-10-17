# Shanika Constructions — Upgrade Test V1.1

මෙය දැනට ඇති Flutter App එක පදනම් කරගෙන සකස් කළ පළමු Upgrade draft එකයි.

## ඇතුළත් කර ඇති දේ
- Navy Blue සහ Gold Dashboard එක; කුඩා card overflow ගැටලුව අඩු කිරීමට card layout වෙනස් කර ඇත.
- Project records: editable Project Number, customer, phone, site, floor, date, notes සහ status.
- Scheduled Projects වෙනම තබා start/end dates, reminder date, estimated amount සහ actual project එකකට convert කිරීම.
- Phone අංක 3ක් දක්වා තබාගත හැකි Customer directory එක.
- Quotation / Actual Bill ලෙස document type එක, amount, paid amount සහ balance පෙන්වන customer document records.
- Finance, workers, mason contacts, project costs, assets, savings, suppliers, stock, site reports, letterhead සහ visiting-card details.
- Slab, Beam, Base Pit, Floor සහ Ready-Mix calculator tabs.
- SharedPreferences මඟින් මේ ෆෝන් එකේම data save කිරීම.

## තවම සම්පූර්ණ නොවූ දේ
- මෙය production-ready සම්පූර්ණ පද්ධතියක් නොවේ; පළමු Upgrade draft එකකි.
- Data මේ ෆෝන් එකේම save වේ. App data clear කිරීමෙන් හෝ uninstall කිරීමෙන් දත්ත නැතිවිය හැක. Backup/Restore screen එක තවම සැබෑ export/import එකක් නොකරයි.
- Branded PDF quotation/bill, print/share, photos, notifications, cloud sync, staff accounts සහ automated reports තවම implement කර නැත.
- Concrete material quantities rough estimates පමණි.
- මෙහි Flutter SDK නොමැති නිසා මේ source එක compile කර තහවුරු කර නැත. Codemagic එකෙන් `flutter pub get`, `flutter analyze` සහ APK build එක පරීක්ෂා කළ යුතුය.

## Codemagic
`codemagic.yaml` එකේ `android-apk` workflow එක තෝරන්න. Build සාර්ථක නම් `build/app/outputs/flutter-apk/app-release.apk` artifact එක ලබාගන්න.
