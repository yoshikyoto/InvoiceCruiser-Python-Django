# プロジェクトとアプリケーション

Django には「プロジェクト」と「アプリケーション」の概念があり、
一つのプロジェクトの中に複数のアプリケーションがあるという構造になっています。

前回作ったのはプロジェクトだったので、今回はその中にアプリケーションを作るところから始めます。

# アプリケーションの作成

Dockerにログインしてアプリケーション作成のコマンドを叩きます。

```sh
# docker が起動していることを確認
$ docker-compose ps
       Name                      Command               State           Ports
-------------------------------------------------------------------------------------
invoice-cruiser-app   python manage.py runserver ...   Up      0.0.0.0:8000->8000/tcp

# 「アプリケーション」を作成
# 今回は「cruiser」というアプリケーションを作成します
root@684c5c3ebff5:/opt/app# python manage.py startapp cruiser
```

# INSTALLED_APPへの追加（重要）

settings.py というファイルがあるかと思います。
僕の場合は、`app` という名前でプロジェクトを作成したので、 
`app/app/settings.py` にあります。

ここに `INSTELLED_APP` という設定項目があるので、ここに先ほど作成したアプリケーションを追加します。

```python

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    # ここより上は最初から追加されていたやつ
    
    # 今回は cruiser というアプリケーションを作成したので
    # cruiser を追加
    'cruiser'
]
```

忘れがちなので必ずやりましょう。やらないと次の Command とかが動きません。

# 今回の差分

* https://github.com/yoshikyoto/InvoiceCruiser-Python-Django/commit/b35bc6ba76f6e310a2e7f698142779c31ef87aac

# 参考

* Django公式ドキュメント
  * https://docs.djangoproject.com/ja/3.0/intro/tutorial01/



--


# Command の作成

バッチ処理を行う「コマンド」を作成します。

heroku の請求書（invoice）を取得する、 `get_heroku_invoice` コマンドを、
先程作成した cruiser アプリの下に `cruiser/management/commands/get_heroku_invoice.py` と
ディレクトリを掘って実装します。

コマンドは `BaseCommand` クラスを継承した `Command` クラスを作成し、
`handle` メソッドにコマンドの本体を実装します。

```python
from django.core.management.base import BaseCommand


class Command(BaseCommand):
    def handle(self, *args, **options):
        print("something!")

```

Docker上でコマンドが動くことを確認します。

```sh
$ python manage.py get_heroku_invoice
something!
```

もしここで unknow command と出た場合は、 `settings.py` の `INSTALLED_APP`
にアプリケーションが追加されていることを確認してください。

```sh
$ python manage.py get_heroku_invoice
Unknown command: 'get_heroku_invoice'
Type 'manage.py help' for usage.
```

# 今回の差分

* https://github.com/yoshikyoto/InvoiceCruiser-Python-Django/commit/6d969fafcd89cb89a89fe7b98066e781241bdc4a

# 参考

* Django公式ドキュメント
  * https://docs.djangoproject.com/ja/3.0/howto/custom-management-commands/
  
  
# django.core.management なのか django.core.management.base なのか

どうでも良い話題。

`django/core/management/__init__.py` の中で 
`from django.core.management.base import BaseCommand` しているので、
多分 `django.core.management.BaseCommand` でも動くんだけど、
公式ドキュメントには `django.core.management.base` って書いてあるし、
僕もソッチのほうが正しいと思うので、 `django.core.management.base` で import しましょう。


--



