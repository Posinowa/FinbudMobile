import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom navigation bar için aktif sekme index'i
/// KAN-80: Aktif sekme Riverpod ile yönetilsin
final navigationIndexProvider = StateProvider<int>((ref) => 0);