mkdir -p /var/www/sirion
cat > /var/www/sirion/index.html <<'HTML'
<!doctype html>
<html>
<head><meta charset="utf-8"><title>War of Wrath: Lindon bertahan</title></head>
<body>
  <h1>War of Wrath: Lindon bertahan</h1>
  <p><a href="/app/">Akses Aplikasi (app.k13.com)</a></p>
  <p><a href="/static/">Akses Static (static.k13.com)</a></p>
</body>
</html>
HTML

chown -R www-data:www-data /var/www/sirion
