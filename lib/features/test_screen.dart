import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/dio_client.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  String _logText = '';

  void _addLog(String message) {
    setState(() {
      _logText += '${DateTime.now().toString().substring(11, 19)} - $message\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interceptor Test'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Test 1: Token Refresh Testi
            ElevatedButton(
              onPressed: () async {
                _addLog('🔄 Token Refresh Testi başlıyor...');
                
                final storage = FlutterSecureStorage();
                
                // Mevcut refresh token'ı sakla (bozulmadan kalsın)
                final refreshToken = await storage.read(key: 'refresh_token');
                _addLog('📦 Refresh token mevcut: ${refreshToken != null}');
                
                // Access token'ı boz
                await storage.write(key: 'access_token', value: 'invalid_token_123');
                _addLog('❌ Access token bozuldu');
                
                // API çağrısı yap
                try {
                  _addLog('📡 API çağrısı yapılıyor: /users/me');
                  final response = await DioClient.instance.get('/users/me');
                  _addLog('✅ Başarılı! Response: ${response.statusCode}');
                } catch (e) {
                  _addLog('🔴 Hata: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test 1: Token Refresh', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 12),
            
            // Test 2: Logout Testi
            ElevatedButton(
              onPressed: () async {
                _addLog('🔄 Logout Testi başlıyor...');
                
                final storage = FlutterSecureStorage();
                
                // Her iki token'ı da boz
                await storage.write(key: 'access_token', value: 'invalid');
                await storage.write(key: 'refresh_token', value: 'invalid');
                _addLog('❌ Her iki token da bozuldu');
                
                // API çağrısı yap
                try {
                  _addLog('📡 API çağrısı yapılıyor...');
                  await DioClient.instance.get('/users/me');
                  _addLog('✅ Başarılı (beklenmedik!)');
                } catch (e) {
                  _addLog('🔴 Hata (beklenen): Logout olmalı');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test 2: Logout', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 12),
            
            // Test 3: Normal API Çağrısı
            ElevatedButton(
              onPressed: () async {
                _addLog('🔄 Normal API testi...');
                
                try {
                  final response = await DioClient.instance.get('/users/me');
                  _addLog('✅ Başarılı: ${response.statusCode}');
                } catch (e) {
                  _addLog('🔴 Hata: $e');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Test 3: Normal API Çağrısı', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 12),
            
            // Token Durumunu Göster
            ElevatedButton(
              onPressed: () async {
                final storage = FlutterSecureStorage();
                final accessToken = await storage.read(key: 'access_token');
                final refreshToken = await storage.read(key: 'refresh_token');
                
                _addLog('--- TOKEN DURUMU ---');
                _addLog('Access: ${accessToken?.substring(0, 20) ?? "YOK"}...');
                _addLog('Refresh: ${refreshToken?.substring(0, 20) ?? "YOK"}...');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.all(16),
              ),
              child: const Text('Token Durumunu Göster', style: TextStyle(color: Colors.white)),
            ),
            
            const SizedBox(height: 12),
            
            // Log Temizle
            TextButton(
              onPressed: () {
                setState(() {
                  _logText = '';
                });
              },
              child: const Text('Logları Temizle'),
            ),
            
            const SizedBox(height: 12),
            
            // Log Alanı
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _logText.isEmpty ? 'Loglar burada görünecek...' : _logText,
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}