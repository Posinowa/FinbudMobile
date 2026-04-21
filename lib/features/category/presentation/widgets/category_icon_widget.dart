// lib/features/category/presentation/widgets/category_icon_widget.dart

import 'package:finbud_app/core/constants/app_color.dart';
import 'package:flutter/material.dart';

/// Kategori ikonu için kullanılabilecek tüm asset path'leri
const List<String> kCategoryIconOptions = [
  'assets/icons/market.png',
  'assets/icons/market_arabasi.png',
  'assets/icons/alisveris_torbasi.png',
  'assets/icons/ev.png',
  'assets/icons/fatura.png',
  'assets/icons/araba.png',
  'assets/icons/ulasim.png',
  'assets/icons/otobus.png',
  'assets/icons/tren.png',
  'assets/icons/taksi.png',
  'assets/icons/motor.png',
  'assets/icons/kamyon.png',
  'assets/icons/ucak.png',
  'assets/icons/bavul.png',
  'assets/icons/yakit_istasyonu.png',
  'assets/icons/lastik.png',
  'assets/icons/restorant.png',
  'assets/icons/catal_kasik.png',
  'assets/icons/yemek_takim.png',
  'assets/icons/pizza.png',
  'assets/icons/kahve.png',
  'assets/icons/firin.png',
  'assets/icons/buzdolabi.png',
  'assets/icons/misir_kola.png',
  'assets/icons/saglik.png',
  'assets/icons/ilac.png',
  'assets/icons/dumbell.png',
  'assets/icons/fitness_salon.png',
  'assets/icons/biberon.png',
  'assets/icons/sinema.png',
  'assets/icons/tiyatro.png',
  'assets/icons/oyun_kolu.png',
  'assets/icons/nota.png',
  'assets/icons/plak.png',
  'assets/icons/cd.png',
  'assets/icons/futbol_topu.png',
  'assets/icons/top.png',
  'assets/icons/kitap.png',
  'assets/icons/defter.png',
  'assets/icons/mezuniyet.png',
  'assets/icons/laptop.png',
  'assets/icons/telefon.png',
  'assets/icons/makyaj.png',
  'assets/icons/buket.png',
  'assets/icons/parti.png',
  'assets/icons/pasta.png',
  'assets/icons/pati.png',
  'assets/icons/tamir.png',
  'assets/icons/para.png',
  'assets/icons/para_gelir.png',
  'assets/icons/para_akis.png',
  'assets/icons/para_kart.png',
  'assets/icons/kredi_kart.png',
  'assets/icons/atm_kart.png',
  'assets/icons/atm.png',
  'assets/icons/atm1.png',
  'assets/icons/qr_odeme.png',
  'assets/icons/gelir_cüzdan.png',
  'assets/icons/hesap_makinesi.png',
  'assets/icons/evrak_cantasi.png',
  'assets/icons/anlasma.png',
  'assets/icons/odul_kupa.png',
  'assets/icons/yildiz.png',
  'assets/icons/yildiz1.png',
  'assets/icons/kalp.png',
  'assets/icons/gunes.png',
  'assets/icons/koli.png',
  'assets/icons/arti.png',
  'assets/icons/eksi.png',
  'assets/icons/unlem.png',
  'assets/icons/artıs.png',
  'assets/icons/azalıs.png',
];

/// Varsayılan ikon
const String kDefaultCategoryIcon = 'assets/icons/koli.png';

/// Eski emoji değerlerini yeni asset ikonlarına eşleştiren map
const Map<String, String> kEmojiToAsset = {
  '🛒': 'assets/icons/market_arabasi.png',
  '🏠': 'assets/icons/ev.png',
  '💡': 'assets/icons/fatura.png',
  '🚗': 'assets/icons/araba.png',
  '🍽️': 'assets/icons/catal_kasik.png',
  '🍔': 'assets/icons/restorant.png',
  '🍗': 'assets/icons/yemek_takim.png',
  '📄': 'assets/icons/fatura.png',
  '🏥': 'assets/icons/saglik.png',
  '🏨': 'assets/icons/saglik.png',
  '🎬': 'assets/icons/sinema.png',
  '👕': 'assets/icons/alisveris_torbasi.png',
  '📚': 'assets/icons/kitap.png',
  '📺': 'assets/icons/misir_kola.png',
  '✈️': 'assets/icons/ucak.png',
  '🎮': 'assets/icons/oyun_kolu.png',
  '💄': 'assets/icons/makyaj.png',
  '🐾': 'assets/icons/pati.png',
  '🔧': 'assets/icons/tamir.png',
  '⚽': 'assets/icons/futbol_topu.png',
  '🎵': 'assets/icons/nota.png',
  '📦': 'assets/icons/koli.png',
  '🛍️': 'assets/icons/alisveris_torbasi.png',
  '☕': 'assets/icons/kahve.png',
  '🍕': 'assets/icons/pizza.png',
  '💊': 'assets/icons/ilac.png',
  '🏋️': 'assets/icons/dumbell.png',
  '🎓': 'assets/icons/mezuniyet.png',
  '🚌': 'assets/icons/otobus.png',
  '🛺': 'assets/icons/taksi.png',
  '🏪': 'assets/icons/market.png',
  '🧾': 'assets/icons/hesap_makinesi.png',
  '📱': 'assets/icons/telefon.png',
  '💻': 'assets/icons/laptop.png',
  '💰': 'assets/icons/para.png',
  '💼': 'assets/icons/evrak_cantasi.png',
  '📈': 'assets/icons/artıs.png',
  '🎁': 'assets/icons/parti.png',
  '🏦': 'assets/icons/atm.png',
  '💵': 'assets/icons/gelir_cüzdan.png',
  '🤝': 'assets/icons/anlasma.png',
  '🏆': 'assets/icons/odul_kupa.png',
  '⭐': 'assets/icons/yildiz.png',
  '🌟': 'assets/icons/yildiz1.png',
};

/// Kategori ikonunu gösteren widget.
/// Asset path ise Image.asset, eski emoji ise mapping'e göre asset gösterir.
class CategoryIconWidget extends StatelessWidget {
  final String icon;
  final double size;

  const CategoryIconWidget({super.key, required this.icon, required this.size});

  @override
  Widget build(BuildContext context) {
    final assetPath = icon.startsWith('assets/') ? icon : kEmojiToAsset[icon];

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.category_outlined, size: size, color: AppColors.textHint),
      );
    }

    return Icon(Icons.category_outlined, size: size, color: AppColors.textHint);
  }
}
