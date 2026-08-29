# Antigravity IDE - Firefox Container Login Setup

Bu paket, Antigravity IDE üzerinden Google ile oturum açarken (`Continue with Google`), bağlantıyı dilediğiniz Firefox Konteynerinde (`Multi-Account Containers`) seçerek açmanızı sağlar.

## Klasör İçeriği
- `Install.bat`: Tek tıkla kurulumu ve yamalamayı gerçekleştirir.
- `Install.ps1`: Kurulum motorudur; `firefox_container.ps1` dosyasını konumlandırır ve `main.js` yedeğini alıp yamalar.
- `Uninstall.bat`: Tek tıkla orijinal `main.js` yedeğini geri yükler.
- `Uninstall.ps1`: Kaldırma motorudur.
- `firefox_container.ps1`: Firefox profilinizdeki konteynerleri otomatik listeleyen ve seçim ekranını sunan scripttir.

## Kullanım
1. Antigravity IDE kapalıyken `Install.bat` dosyasını çift tıklayarak çalıştırınız.
2. IDE'yi açıp `Continue with Google` butonuna basınız.
3. Ekrana gelen listeden dilediğiniz Gmail konteynerini seçip `Enter` tuşuna basınız.

## IDE Güncellendiğinde
Antigravity IDE güncellendiğinde `main.js` dosyası sıfırlanırsa, tek yapmanız gereken `Install.bat` dosyasını bir kez tekrar çalıştırmaktır.
