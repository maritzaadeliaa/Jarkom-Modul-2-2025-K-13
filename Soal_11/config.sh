server {
    listen 80 default_server;
    server_name sirion.k13.com www.k13.com havens.k13.com;

    # Reverse proxy rules
    location /static/ {
        proxy_pass http://10.70.3.5/;            # Lindon
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    location /app/ {
        proxy_pass http://10.70.3.6/;            # Vingilot
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # /admin (akan ditambahkan di nomor 12)
    
    # Root homepage (nomor 20)
    location = / {
        root /var/www/sirion;
        index index.html;
    }
}
