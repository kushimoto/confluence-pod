# Readmine Pod

これは個人的に confluence を Podman の Pod で構築するために作ったメモです。  
利用において私は責任を持ちません。
(というか試行錯誤の反映漏れがあって動かないかもしれない...)

## 使い方

この Pod には２つのコンテナが含まれます。

- confluence 
- Postgresql

※ すべての作業は root ユーザーで進めます。

### コンテナイメージのDL
以下のイメージを利用しておりますので、予めダウンロードしておきます。

- docker.io/atlassian/confluence:9.1-ubuntu-jdk21
- docker.io/library/postgres:16.4-bullseye

```shell
podman pull docker.io/atlassian/confluence:9.1-ubuntu-jdk21
podman pull docker.io/library/postgres:16.4-bullseye
```

### confluence-pod.yml の書き換え

環境変数などは自分で書き換えましょう。(言いたいのはそれだけ)

### 初期化

以下のスクリプトを実行します。

```shell
git clone https://github.com/kushimoto/confluence-pod.git
cd confluence-pod
bash init.sh
```

### 登録

以下のコマンドを実行します

```shell
/usr/libexec/podman/quadlet /usr/share/containers/systemd/confluence-pod.kube 
systemctl daemon-reload
systemctl start confluence-pod.service
```

### WEBUI

http://{サーバーのIPアドレス}}:8090 でアクセスできます

selinux が有効な場合は下記コマンドが必要かもしれない。(ファイアウォールはまだ検索しやすいので書かないぞ :heart: )

```shell
semanage port -a -t http_port_t -p tcp 8090
```

### メモ欄

- Podを作る

```shell
podman pod create --name confluence -p 8090:8090 -p 8091:8091 --network slirp4netns
```

- コンテナを作る

```shell
podman run -d --name db --pod confluence  \
  -e POSTGRES_DB=confluence \
  -e POSTGRES_USER=confluence \
  -e POSTGRES_PASSWORD=confluence \
  -v /opt/confluence-pod/data/db:/var/lib/postgresql/data:Z \
  docker.io/library/postgres:16.4-bullseye

podman run -d --name app --pod confluence  \
  -e ATL_JDBC_URL=jdbc:postgresql://127.0.0.1:5432/confluence \
  -e ATL_JDBC_USER=confluence \
  -e ATL_JDBC_PASSWORD=confluence \
  -e ATL_DB_TYPE=postgresql \
  -e ATL_DB_DRIVER=org.postgresql.Driver \
  -e ATL_DB_SCHEMA_NAME=public \
  -v /opt/confluence-pod/data/app:/var/atlassian/application-data/confluence:Z \
  docker.io/atlassian/confluence:9.1-ubuntu-jdk21
```

- YAMLを吐き出す

```shell
podman generate kube confluence
```
