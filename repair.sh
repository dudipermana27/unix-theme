if (( $EUID != 0 )); then
    echo "Tolong jalankan sebagai root"
    exit
fi

repairPanel(){
    cd /var/www/pterodactyl

    php artisan down

    rm -r /var/www/pterodactyl/resources

    curl -L https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz | tar -xzv

    chmod -R 755 storage/* bootstrap/cache

    composer install --no-dev --optimize-autoloader

    php artisan view:clear

    php artisan config:clear

    php artisan migrate --seed --force

    chown -R www-data:www-data /var/www/pterodactyl/*

    chown -R nginx:nginx /var/www/pterodactyl/*

    chown -R apache:apache /var/www/pterodactyl/*

    php artisan queue:restart

    php artisan up
}

while true; do
    read -p "Kamu beneran mau repair tema ini [y/n]? " yn
    case $yn in
        [Yy]* ) repairPanel; break;;
        [Nn]* ) exit;;
        * ) echo "Tolong jawab y atau n.";;
    esac
done
