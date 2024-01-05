#!/bin/bash

# Verifikasi apakah user yang menjalankan script adalah root user atau bukan
if (( $EUID != 0 )); then
    echo "Tolong Jalankan sebagai root"
    exit
fi

clear

# Fungsi untuk membuat backup dari directory pterodactyl
installTheme(){
    cd /var/www/pterodactyl
    php artisan down
    echo "Memasang tema...tunggu ya"
    unzip unix.zip
    cd /var/www/pterodactyl
    rm -r unix
    chmod -R 755 storage/* bootstrap/cache
    composer install --no-dev --optimize-autoloader
    php artisan view:clear
    php artisan config:clear
    php artisan migrate --seed --force
    chown -R www-data:www-data /var/www/pterodactyl/*
    cd /var/www/pterodactyl

    # Install dependencies
    chown -R nginx:nginx /var/www/pterodactyl/*
    apt update
    php artisan queue:restart

    php artisan up

    cd /var/www/pterodactyl
    php artisan optimize:clear
}

# Fungsi untuk menanyakan user apakah yakin ingin menginstall theme atau tidak
installThemeQuestion(){
    while true; do
        read -p "Kamu beneran mau memasang tema ini [y/n]? " yatidak
        case $yatidak in
            [Yy]* ) installTheme; break;;
            [Nn]* ) exit;;
            * ) echo "Tolong jawab y(ya) atau n(tidak).";;
        esac
    done
}

# Fungsi untuk memperbaiki panel jika terjadi error pada saat menginstall theme
repair(){
    bash <(curl https://raw.githubusercontent.com/mufniDev/nightDy/main/repair.sh)
}

# Fungsi untuk mengembalikan backup dari directory pterodactyl
restoreBackUp(){
    echo "Memulihkan cadangan..."
    cd /var/www/
    tar -xvf nightDy.tar.gz
    rm nightDy.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    php artisan optimize:clear
}

# Menampilkan menu pilihan
echo "Copyright © ClaqNode Hosting"
echo "script ini 100% GRATIS, anda bisa mengedit, mendistribusikan."
echo "Tapi anda tidak boleh memperjual belikan script ini tanpa seijin developer"
echo "#RespectTheDevelopers"
echo ""
echo "Discord:-"
echo "GitHub: https://github.com/ClaqNode-Hosting"
echo "Website: https://www.claqnode.my.id"
echo ""
echo "[1] Pasang tema"
echo "[2] perbaiki panel (gunakan jika mengalami error)"
echo "[3] Keluar"

# Meminta user untuk memilih pilihan
read -p "Mohon masukkan angka: " choice

# Menjalankan pilihan yang dipilih oleh user
if [ $choice == "1" ]; then
    installThemeQuestion
fi

if [ $choice == "2" ]; then
    repair
fi

if [ $choice == "3" ]; then
    exit
fi
