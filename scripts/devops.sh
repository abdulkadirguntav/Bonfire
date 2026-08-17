#!/usr/bin/env bash
# ==============================================================================
# Bonfire DevOps Unified CLI Toolkit
# ==============================================================================
set -e

COLOR_RESET="\033[0m"
COLOR_GOLD="\033[38;5;220m"
COLOR_GREEN="\033[38;5;82m"
COLOR_RED="\033[38;5;196m"
COLOR_CYAN="\033[38;5;51m"

print_banner() {
    echo -e "${COLOR_GOLD}"
    echo "============================================================"
    echo "  🔥 BONFIRE — DEVOPS AUTOMATION CLI"
    echo "============================================================"
    echo -e "${COLOR_RESET}"
}

usage() {
    print_banner
    echo -e "Kullanım: ./scripts/devops.sh [komut]"
    echo ""
    echo "Komutlar:"
    echo "  analyze         - Flutter statik kod analizini çalıştırır"
    echo "  test            - Tüm birim ve widget testlerini çalıştırır"
    echo "  coverage        - Testleri çalıştırır ve test kapsama raporu üretir"
    echo "  docker-build    - Çok aşamalı (Multi-Stage) Docker imajını derler"
    echo "  docker-run      - Docker konteynerini başlatır (http://localhost:8080)"
    echo "  docker-ci       - Docker içinde izole test ve analiz çalıştırır"
    echo "  build-apk       - Production Release APK dosyasını derler"
    echo "  build-web       - Production Flutter Web bundle dosyasını derler"
    echo "  ci              - Tam CI döngüsünü (format, analyze, test) çalıştırır"
    echo ""
}

case "$1" in
    analyze)
        echo -e "${COLOR_CYAN}🔍 Statik analiz çalıştırılıyor...${COLOR_RESET}"
        flutter analyze
        echo -e "${COLOR_GREEN}✓ Analiz hatasız tamamlandı!${COLOR_RESET}"
        ;;
    test)
        echo -e "${COLOR_CYAN}🧪 Testler çalıştırılıyor...${COLOR_RESET}"
        flutter test
        echo -e "${COLOR_GREEN}✓ Tüm testler başarıyla geçti!${COLOR_RESET}"
        ;;
    coverage)
        echo -e "${COLOR_CYAN}📊 Test kapsama analizi yapılıyor...${COLOR_RESET}"
        flutter test --coverage
        echo -e "${COLOR_GREEN}✓ Kapsama raporu 'coverage/lcov.info' konumuna yazıldı.${COLOR_RESET}"
        ;;
    docker-build)
        echo -e "${COLOR_CYAN}🐳 Docker imajı derleniyor (Multi-Stage)...${COLOR_RESET}"
        docker build -t bonfire:latest -f Dockerfile .
        echo -e "${COLOR_GREEN}✓ Docker imajı 'bonfire:latest' başarıyla oluşturuldu!${COLOR_RESET}"
        ;;
    docker-run)
        echo -e "${COLOR_CYAN}🚀 Docker konteyneri başlatılıyor...${COLOR_RESET}"
        docker compose up -d bonfire-web
        echo -e "${COLOR_GREEN}✓ Uygulama http://localhost:8080 adresinde yayında!${COLOR_RESET}"
        ;;
    docker-ci)
        echo -e "${COLOR_CYAN}🐳 Docker içinde izole CI çalıştırılıyor...${COLOR_RESET}"
        docker compose run --rm bonfire-ci
        ;;
    build-apk)
        echo -e "${COLOR_CYAN}📦 Release APK derleniyor...${COLOR_RESET}"
        flutter build apk --release
        echo -e "${COLOR_GREEN}✓ APK: build/app/outputs/flutter-apk/app-release.apk${COLOR_RESET}"
        ;;
    build-web)
        echo -e "${COLOR_CYAN}🌐 Production Web bundle derleniyor...${COLOR_RESET}"
        flutter build web --release
        echo -e "${COLOR_GREEN}✓ Web: build/web${COLOR_RESET}"
        ;;
    ci)
        print_banner
        echo -e "${COLOR_CYAN}1/3 Format kontrolü...${COLOR_RESET}"
        dart format --output=none --set-exit-if-changed .
        echo -e "${COLOR_CYAN}2/3 Statik analiz...${COLOR_RESET}"
        flutter analyze
        echo -e "${COLOR_CYAN}3/3 Birim testleri...${COLOR_RESET}"
        flutter test
        echo -e "${COLOR_GREEN}🎉 Tüm CI adımları başarıyla tamamlandı!${COLOR_RESET}"
        ;;
    *)
        usage
        exit 1
        ;;
esac
