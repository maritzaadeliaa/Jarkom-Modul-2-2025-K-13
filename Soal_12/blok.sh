location /admin {
    auth_basic "Restricted Admin";
    auth_basic_user_file /etc/nginx/.htpasswd;

    proxy_pass http://10.70.3.6/admin;   # atau lokasi admin di backend
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
