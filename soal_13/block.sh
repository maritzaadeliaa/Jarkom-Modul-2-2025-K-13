# redirect server (catch IP and sirion.k13.com)
server {
    listen 80;
    server_name 10.70.3.2 sirion.k13.com;

    return 301 http://www.k13.com$request_uri;
}
