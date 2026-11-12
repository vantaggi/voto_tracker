import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

/// I1-I4: icona "Stanghette" e splash. Controlla che i file generati da
/// `scripts/make_icons.py` ci siano, con le misure giuste, e che manifest e
/// temi li usino (lo splash vero si guarda sul telefono).
void main() {
  const res = 'android/app/src/main/res';

  /// (larghezza, altezza, ha l'alfa) dall'intestazione del PNG.
  (int, int, bool) png(String path) {
    final b = ByteData.sublistView(File(path).readAsBytesSync());
    return (b.getUint32(16), b.getUint32(20), b.getUint8(25) == 6);
  }

  test('Android: icona adaptive con livello monocromatico', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    expect(manifest, contains('android:icon="@mipmap/ic_launcher"'));
    expect(manifest, contains('android:label="@string/app_name"'));
    final adaptive = File('$res/mipmap-anydpi-v26/ic_launcher.xml')
        .readAsStringSync();
    for (final part in [
      '@color/ic_launcher_background',
      '@drawable/ic_launcher_foreground',
      '@drawable/ic_launcher_monochrome',
    ]) {
      expect(adaptive, contains(part));
    }
    const sizes = {
      'mdpi': 48,
      'hdpi': 72,
      'xhdpi': 96,
      'xxhdpi': 144,
      'xxxhdpi': 192,
    };
    for (final e in sizes.entries) {
      final (w, h, _) = png('$res/mipmap-${e.key}/ic_launcher.png');
      expect((w, h), (e.value, e.value), reason: e.key);
      expect(
        File('android/app/src/debug/res/mipmap-${e.key}/ic_launcher.png')
            .existsSync(),
        isTrue,
      );
      expect(
        File('$res/drawable-${e.key}/splash_icon.png').existsSync(),
        isTrue,
      );
      expect(
        File('$res/drawable-night-${e.key}/splash_icon.png').existsSync(),
        isTrue,
      );
    }
  });

  test('splash: Android 12+ chiaro e scuro, fondo uguale alla finestra', () {
    for (final dir in ['values-v31', 'values-night-v31']) {
      final styles = File('$res/$dir/styles.xml').readAsStringSync();
      expect(styles, contains('windowSplashScreenBackground'));
      expect(styles, contains('windowSplashScreenAnimatedIcon'));
      expect(styles, contains('windowSplashScreenIconBackgroundColor'));
    }
    for (final dir in ['values', 'values-night']) {
      final styles = File('$res/$dir/styles.xml').readAsStringSync();
      expect(styles, contains('@drawable/launch_background'));
      expect(styles, contains('@color/splash_background'));
    }
    expect(Directory('$res/drawable-v21').existsSync(), isFalse);
  });

  test('Play Store, web e iOS', () {
    // Play Store: PNG a 32 bit.
    expect(png('assets/icon/play_store_512.png'), (512, 512, true));
    expect(png('web/icons/Icon-512.png').$1, 512);
    expect(png('web/icons/Icon-maskable-192.png').$1, 192);
    // iOS rifiuta l'icona da 1024 con la trasparenza.
    expect(
      png(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png',
      ),
      (1024, 1024, false),
    );
  });
}
