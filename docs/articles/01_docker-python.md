DockerでPythonの開発環境を作成する

# なぜPythonを使うのか

高機能

* 便利な Model と Migration
* 管理ツール
* 強い REST framework

# 環境

私は Mac を利用していますが、 Docker を使っていくので、
基本的には Windwos でも問題ないはずです。

# Django を入れる

Python はインストール済みだとします。Python 3 を利用します。
Mac の場合は python3 というコマンドで使えると思います。

```sh
$ python3 --version
Python 3.7.6
```

Mac の場合は pip3 で django をインストールできます。

```sh
pip3 install django
```

# Django アプリケーションの作成

django をインストールしたことで、 django-admin コマンドが使えるようになっているはず。

今回は InvoiceCruiser というアプリを作成するのだが、

* InvoiceCruiser （アプリのルートディレクトリ）
  * app
  * Dockerfile
  * ...

のようなファイル構成にしたい。

```sh
mkdir InvoiceCruiser
cd InvoiceCruiser
django-admin startproject app
```

ここでついでにまるっとgit管理しておく。
gitコマンドはインストール済みであるとする。

```sh
git init
git add .
git commit -m "initial commit"
```

# DockerでPythonの開発環境を作成する

## requirements.txt の用意

Dockerをインストールするのに必要なパッケージを書いた
`requirements.txt` を用意します。

```requirements.txt
Django==3.0.3
```

## Dockerfile の作成

続いて、 `Dockerfile` を作成します。
この Dockerfile はまだ動作確認用です。

```Dockerfile
FROM python:3

RUN mkdir -p /opt
COPY requirements.txt /opt/requirements.txt
COPY app /opt/app

WORKDIR /opt
RUN pip install -r requirements.txt

WORKDIR app
CMD python manage.py runserver
```

## Docker のビルド

このDockerのビルドスプリクトを書きます。
`bin/build-docker.sh` とします。

```sh
#!/bin/sh

docker build --tag="invoice-cruiser-app"
```

コマンドを実行します。
必ず `Dockerfile` と同じディレクトリで実行してください。

```sh
sh bin/build-docker.sh
```

## docker-compose

`docker-compose.yml` も用意します。

```yml
version: "3"
services:
  app:
    image: invoice-cruiser-app
    container_name: invoice-cruiser-app
    ports:
      - 8000:8000
    command: python manage.py runserver 0.0.0.0:8000
```

docker を立ち上げます。

```sh
docker-compose up -d
```

localhost:8000 に接続すると見られるはずです。

## ディレクトリが同期されるように

現状だと、ビルドした時のアプリケーションから更新されないので、
更新が同期されるようにします。

`docker-compose.yml` を書き換える前に、
必ず docker-compose を終了させておきます。
終了する前に yml を書き換えてしまうと大変なことになります。

```sh
docker-compose down
```

`docker-compose.yml` を書き換えます。

* `./app` のように `./` を書かないとうまく動かないようです。

```yml
version: "3"
services:
  app:
    image: invoice-cruiser-app
    container_name: invoice-cruiser-app
    ports:
      - 8000:8000
    # volumes を追記
    volumes:
      - ,.app:/opt/app
    command: python manage.py runserver 0.0.0.0:8000
```

再び docker-compose を起動します。

```sh
docker-compose up -d
```

何も変わってないですが、 localhost:8000 で接続できます。


# 続きは次回

何かわからないことがありましたら、コメントやtwitterなどで気軽に質問してください。
忙しくなければ答えます。

参考

* https://docs.djangoproject.com/ja/3.0/intro/tutorial01/
* リポジトリは https://github.com/yoshikyoto/InvoiceCruiser-Python-Django
  * 今回の変更は https://github.com/yoshikyoto/InvoiceCruiser-Python-Django/commit/84389992d677bab9bdaa6778cda5f69b4043a471
  