#!/bin/sh
base='scapo'
fecha=`date '+%Y%m%d-%H%M%S'`
file="0_${base}_${fecha}"
raiz='/var/www/localhost/htdocs/vhost/'
dcfg="-h localhost -p 5432 -U postgres -F c -b  -f"
omitir="*zip *json *backup *html *png *jpg *js *css *sublime* ./respaldos/*"
zcfg="-qr9"
# zcfg="-vr9"
# - - ARCIVO - - - - - - - - - - - - - - - - - - - -
# comprimir sistema produccion dentro de carpeta de desarrollo
cd "${raiz}jos.miagenda.club/"
zip $zcfg "${raiz}dev.miagenda.club/${file}.s.zip" ./ -x $omitir
cd "${raiz}dev.miagenda.club/"
# respaldar sistema desarrollo
zip $zcfg "./respaldos/${file}.s.zip" ./ -x $omitir
# sustituir sistema y ajustar
unzip -qXo "${file}.s.zip" -d ./
chown jose:jose -R ./*
chmod -R 755 ./*
sed -i 's/scapo/scapo_dev/g' ./_cfg_.php
sed -i 's/206bc4/74b816/g' ./_cfg_.php
rm "${file}.s.zip"
# - - - BASE DE DATOS - - - - - - - - - - - - - - - -
# respaldar y comprimir base
pg_dump $dcfg "./${file}.backup" "${base}_dev"
zip $zcfg "./respaldos/${file}.b.zip" "${file}.backup"
# - - - - - - - - - - - - - - - - - - - - - -
# clonar base
pg_dump $dcfg "./${file}.backup" $base
pg_restore --clean -h localhost -p 5432 -U postgres -d "${base}_dev" "${file}.backup"
rm "${file}.backup"
