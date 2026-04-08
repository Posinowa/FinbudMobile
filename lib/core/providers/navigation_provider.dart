import 'package:flutter_riverpod/legacy.dart';

/// Bottom navigation bar için aktif sekme index'i
/// KAN-80: Aktif sekme Riverpod ile yönetilsin
final navigationIndexProvider = StateProvider<int>((ref) => 0);