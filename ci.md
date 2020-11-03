### Docker

```sh
mkdir -p /data/nfs/nginx-static/sentry-go-handbook
chmod -R 777 /data/nfs/nginx-static/sentry-go-handbook
docker build -t xx.com/library/sentry-go-handbook:ci .
docker push xx.com/library/sentry-go-handbook:ci

git checkout -b release/cloud
```