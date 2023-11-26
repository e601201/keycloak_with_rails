# README

```
$ docker compose -f keycloak/docker-compose.yml up
```

```
$ bundle install
$ rails db:create
$ rails db:migrate
$ bin/rails s
```

```
セッション管理はRedisを用いているので、ローカルで立ち上げる際はRedisも立ち上げること
brew install redis 
redis-server

```
