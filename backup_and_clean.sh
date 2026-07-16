#!/bin/bash

# 1. Değişkenleri Tanımlayalım (Tarih formatı ve klasör yolları)
TARIH=$(date +"%Y-%m-%d_%H-%M-%S")
LOG_DOSYASI="logs/app.log"
YEDEK_KLASORU="backups"

# 2. Yedekleme klasörü yoksa otomatik oluştur
mkdir -p "$YEDEK_KLASORU"

# 3. Log dosyasını tar.gz formatında sıkıştırarak yedekle
tar -czf "$YEDEK_KLASORU/log_backup_$TARIH.tar.gz" "$LOG_DOSYASI"

# 4. Yedeklemenin başarılı olup olmadığını kontrol et ($? son komutun durumunu verir, 0 ise başarılıdır)
if [ $? -eq 0 ]; then
    echo "[$TARIH] BAŞARILI: Log dosyası sıkıştırıldı ve yedeklendi."
    
    # 5. Orijinal log dosyasının içini temizle (Dosyayı silmiyoruz, sadece sıfırlıyoruz)
    cat /dev/null > "$LOG_DOSYASI"
    echo "[$TARIH] BAŞARILI: Orijinal log dosyasının içi temizlendi."
else
    echo "[$TARIH] HATA: Yedekleme sırasında bir hata oluştu!"
    exit 1
fi