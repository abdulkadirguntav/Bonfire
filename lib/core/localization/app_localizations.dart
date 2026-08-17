import 'dart:ui';
import 'package:flutter/widgets.dart';

class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    final loc = Localizations.maybeLocaleOf(context) ??
        PlatformDispatcher.instance.locale;
    return AppLocalizations(loc);
  }

  static AppLocalizations get current =>
      AppLocalizations(PlatformDispatcher.instance.locale);

  bool get isTurkish => locale.languageCode.toLowerCase() == 'tr';

  // Branding
  String get appTitle => 'Bonfire';
  String get tagline => isTurkish ? 'KÜL VE İRADE' : 'ASH AND WILL';

  // Navigation Tabs
  String get tabBonfire => isTurkish ? 'Ateş' : 'Bonfire';
  String get tabShop => isTurkish ? 'Fırın' : 'The Kiln';
  String get tabReflection => isTurkish ? 'Muhasebe' : 'Reflection';
  String get tabRecord => isTurkish ? 'Kayıt' : 'Ashen Record';
  String get tabRoadmap => isTurkish ? 'YOL HARİTASI' : 'ROADMAP';
  String get tabSoapstone => isTurkish ? 'KADİM İZLER' : 'SOAPSTONE';

  // Top Bar & Badges
  String get streakDay => isTurkish ? 'GÜN' : 'DAY';
  String get marketOpen => isTurkish ? 'PAZAR AÇIK' : 'MARKET OPEN';
  String get marketClosed => isTurkish ? 'PAZAR KAPALI' : 'MARKET CLOSED';
  String get bonfireReady => isTurkish ? 'YAKILABİLİR' : 'KINDLE READY';

  // Stats / Vitals
  String get health => isTurkish ? 'CAN' : 'HP';
  String get stamina => isTurkish ? 'STAMINA' : 'STAMINA';
  String get essence => isTurkish ? 'ÖZ' : 'ESSENCE';
  String get streak => isTurkish ? 'GÜN SERİSİ' : 'STREAK';

  // Vows / Tasks
  String get vowsTitle => isTurkish ? 'GÜNLÜK YEMİNLER' : 'DAILY VOWS';
  String get addVow => isTurkish ? 'Yeni Yemin Ekle' : 'Add New Vow';
  String get noVows => isTurkish
      ? 'Henüz bir yemin edilmedi. Ateşini harlamak için bir yemin ekle.'
      : 'No vows sworn yet. Add a vow to kindle the flame.';
  String get vowCompleted => isTurkish ? 'Tamamlandı' : 'Completed';
  String get deleteVowTitle =>
      isTurkish ? 'Yemini İptal Et' : 'Forsake Vow';
  String get deleteVowConfirm => isTurkish
      ? 'Bu yemini silmek istediğine emin misin? Harcanan Stamina karakterine iade edilecektir.'
      : 'Are you sure you want to forsake this vow? Consumed Stamina will be refunded to your character.';
  String get delete => isTurkish ? 'SİL' : 'DELETE';
  String get cancel => isTurkish ? 'VAZGEÇ' : 'CANCEL';
  String get habitTime => isTurkish ? 'Hatırlatıcı Saati' : 'Reminder Time';

  // Boss
  String get bossTitle => isTurkish ? 'KADİM DÜŞMAN' : 'ANCIENT FOE';
  String get strikeBoss => isTurkish ? 'DARBE VUR' : 'STRIKE BOSS';
  String get bossStruckToday =>
      isTurkish ? 'BUGÜN VURULDU' : 'STRUCK TODAY';
  String get bossHp => isTurkish ? 'BOSS CANI' : 'BOSS HP';
  String get bossFailed =>
      isTurkish ? 'Bugün Yeminler Bozuldum (Yenilgi)' : 'Failed Vows Today';

  // Shop / The Kiln
  String get shopTitle => isTurkish ? 'KADİM FIRIN (PAZAR)' : 'THE KILN (MARKET)';
  String get buy => isTurkish ? 'SATIN AL' : 'PURCHASE';
  String get use => isTurkish ? 'KULLAN' : 'USE';
  String get inventory => isTurkish ? 'ENVANTER' : 'INVENTORY';
  String get owned => isTurkish ? 'Sahip Olunan' : 'Owned';
  String get marketClosedDesc => isTurkish
      ? 'Seyyar tüccar yalnızca belirli Bonfire günlerinde (Gün 5, 10, 15...) açılır.'
      : 'The travelling merchant only appears on Bonfire days (Day 5, 10, 15...).';

  // Reflection (Gün Sonu)
  String get reflectionTitle =>
      isTurkish ? 'GÜN SONU MUHASEBESİ' : 'EVENING REFLECTION';
  String get sealAndRest =>
      isTurkish ? 'MÜHÜRLE VE DİNLEN' : 'SEAL AND REST';
  String get reflectionSaved =>
      isTurkish ? 'Muhasebe mühürlendi ve kaydedildi.' : 'Reflection sealed and recorded.';

  // Soapstone Notes
  String get soapstoneTitle =>
      isTurkish ? 'RUH TAŞI NOTLARI' : 'SOAPSTONE MESSAGES';
  String get leaveMessage =>
      isTurkish ? 'Mesaj Bırak' : 'Leave Message';
  String get writeSoapstone =>
      isTurkish ? 'Kadim bir söz veya not bırak...' : 'Carve a message in stone...';

  // Death Screen
  String get youDied => isTurkish ? 'ÖLDÜN' : 'YOU DIED';
  String get rebirth => isTurkish ? 'YENİDEN DOĞ' : 'REBIRTH';
  String get lostEssence =>
      isTurkish ? 'Kaybedilen Öz (Essence):' : 'Lost Essence:';
  String get targetStreak =>
      isTurkish ? 'Hedef Gün Serisi:' : 'Target Streak:';
  String get deathDesc => isTurkish
      ? 'Küllerinden yeniden doğ!\n1. günden başlayıp aynı gün serisine ulaştığında kaybettiğin tüm Öz\'ü geri kazanacaksın.\nAncak hedefe ulaşamadan tekrar ölürsen eski izin sonsuza dek silinir.'
      : 'Rise again from the ashes!\nStart anew from Day 1 and reach your target streak to reclaim your lost Essence.\nIf you perish again before reaching the mark, your ashes will be lost forever.';

  // Ashen Record & Attributes
  String get recordTitle =>
      isTurkish ? 'KÜL KAYDI VE NİTELİKLER' : 'THE ASHEN RECORD';
  String get attributesTitle =>
      isTurkish ? 'NİTELİKLER (STATS)' : 'ATTRIBUTES (STATS)';
  String get chronicleTitle =>
      isTurkish ? 'KÜL GEÇMİŞİ (GEÇMİŞ)' : 'THE CHRONICLE';
  String get levelUp => isTurkish ? 'GELİŞTİR' : 'LEVEL UP';
  String get bonfireRequiredToLevel => isTurkish
      ? 'Nitelik yükseltme yalnızca Bonfire günlerinde (Gün 3, 7, 14, 30...) yapılabilir.'
      : 'Attributes can only be upgraded at a Bonfire (Day 3, 7, 14, 30...).';

  // Danger Zone / Wipe
  String get dangerZone => isTurkish ? 'TEHLİKELİ BÖLGE' : 'DANGER ZONE';
  String get wipeCharacter =>
      isTurkish ? 'KARAKTERİ VE TÜM VERİLERİ SİL' : 'DELETE CHARACTER & ALL PROGRESS';
  String get wipeConfirmTitle =>
      isTurkish ? 'Küllere Dönüş (Tam Sıfırlama)' : 'Return to Ashes (Full Reset)';
  String get wipeConfirmDesc => isTurkish
      ? 'DİKKAT: Karakter sınıfın, kazandığın tüm Özler, yeminlerin, boss ilerlemen ve notların kalıcı olarak silinecektir.\nBu işlem geri alınamaz!'
      : 'WARNING: Your character class, all earned Essence, vows, boss progress, and chronicle records will be permanently erased.\nThis action cannot be undone!';
  String get confirmWipe =>
      isTurkish ? 'EVET, HER ŞEYİ SİL' : 'YES, ERASE EVERYTHING';

  // Notifications
  String get testNotification =>
      isTurkish ? 'BİLDİRİMİ TEST ET' : 'TEST NOTIFICATION';
  String get testNotificationSent => isTurkish
      ? 'Test bildirimi gönderildi! Lütfen bildirim çubuğunu kontrol edin.'
      : 'Test notification sent! Please check your notification drawer.';

  // Onboarding
  String get choosePath =>
      isTurkish ? 'Sınıfını Seç ve Başla' : 'Choose Your Path';
  String get choosePathSubtitle => isTurkish
      ? 'Her sınıf farklı irade gücüne, dayanıklılığa ve öz kazancına sahiptir.'
      : 'Each class possesses distinct fortitude, stamina, and essence mastery.';
  String get beginJourney =>
      isTurkish ? 'YOLCULUĞA BAŞLA' : 'BEGIN JOURNEY';

  // Item Names & Descs
  String itemName(String id) {
    if (!isTurkish) {
      switch (id) {
        case 'estus_flask':
          return 'Estus Flask';
        case 'ashen_estus':
          return 'Ashen Estus';
        case 'purging_stone':
          return 'Purging Stone';
        case 'scroll_of_stasis':
          return 'Scroll of Stasis';
        case 'ring_of_sacrifice':
          return 'Ring of Sacrifice';
        default:
          return id;
      }
    }
    switch (id) {
      case 'estus_flask':
        return 'Estus Şişesi';
      case 'ashen_estus':
        return 'Kül Estusu';
      case 'purging_stone':
        return 'Arınma Taşı';
      case 'scroll_of_stasis':
        return 'Zaman Mührü';
      case 'ring_of_sacrifice':
        return 'Fedakarlık Yüzüğü';
      default:
        return id;
    }
  }

  // Class Names
  String className(String id) {
    if (!isTurkish) {
      switch (id.toLowerCase()) {
        case 'mage':
          return 'Mage';
        case 'warrior':
          return 'Warrior';
        case 'prisoner':
          return 'Prisoner';
        default:
          return id;
      }
    }
    switch (id.toLowerCase()) {
      case 'mage':
        return 'Büyücü';
      case 'warrior':
        return 'Savaşçı';
      case 'prisoner':
        return 'Mahkum';
      default:
        return id;
    }
  }
}
