import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';

class NetworkUnavailableWidget extends StatelessWidget {
  const NetworkUnavailableWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.blue),
            const SizedBox(height: 16),
            const Text(
              'الرجاء تفعيل Wi-Fi للمتابعة\nوربط الطابعة على نفس الشبكة',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                AppSettings.openAppSettings(type: AppSettingsType.wifi);
              },
              child: const Text('تفعيل Wi-Fi'),
            )
          ],
        ),
      ),
    );
  }
}
