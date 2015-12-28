# aws-tool-ami

AMIのバックアップを行うコマンドラインツールです。RubyのGemとしてパッケージングされています。

## インストール

下記のGemfileを任意のディレクトリに作成します。

```ruby
source 'https://rubygems.org'
gem "aws-tool-ami", :git => "git@github.com:petgojp/aws-tool-ami.git", :branch => "master"
```

Gemfileのあるディレクトリで下記のコマンドを実行します。

```bash
$ bundle install
```

## 利用方法

bundle exec aws-tool-amiでヘルプが表示されます。

```bash
$ bundle exec aws-tool-ami
Commands:
  console create_ami [STACK_NAME] --config=CONFIG    # Create AMI of instances which belongs to specified stack
  console help [COMMAND]                             # Describe available commands or one specific command
  console scavenge_ami [STACK_NAME] --config=CONFIG  # Scavenge outdated AMIs which belongs to specified stack
```

#### create_ami

AMIを作成します。インスタンスの再起動は発生しません。

```
$ bundle exec aws-tool-ami create_ami corp --config ./config.json
```

#### scavenge_ami

作成後一定期間経過したAMIを削除します。

```
$ bundle exec aws-tool-ami scavenge_ami corp --config ./config.json
```

#### config.json

configで渡すJSONファイルは下記の内容になります。

```json
{
  "credentials": {
    "access_key_id": "access_key_id",
    "secret_access_key": "secret_access_key"
  }
}
```