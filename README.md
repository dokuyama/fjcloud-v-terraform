# FJcloud-V Terraform

## 概要
FJcloud-Vのインフラ構成部分を自動化する事を目的とする。

プロジェクトごとのディレクトリを作成し、tfファイルはシンボリックリンクで作成し、共通で利用し、設定が必要なものは全て tfvarsファイルにて設定を行う。

原則としては サブディレクトリの *.tf はシンボリックリンクだが、例外的な処理を追加する事ができるように、実体のファイルとして分岐する事ができる事を想定した。

このコードで作成できる環境については、[docs/vars-config-samples.md](https://github.com/dokuyama/fjcloud-v-terraform/blob/main/docs/vars-config-samples.md) を参照すること。

## 使い方

以下のスクリプトで、プロジェクト名のディレクトリ、tfvarsファイルのテンプレート、tfファイルのリンク、登録するssh公開鍵とその秘密鍵を作成する。

```
$ ./_make_tfvars.sh プロジェクト名
```

各設定にプロジェクト名をPrefixとして利用する事を想定しているが、FJcloud-Vの文字列の制約により、プロジェクト名は
アルファベット小文字の4～8文字 (^[a-z]{4,8}) という制約を入れている。

作成後、以下の流れで環境を作成する。

```
$ cd [プロジェクト名]
$ vi terraform.tfvars.[プロジェクト名]
(ここで各種設定を記述する※ファイル内コメントを参照、設定可能な値はvariables.tfを参照すること。
必須な設定は、access_key, secret_key, public_key となる。)
$ terraform init
$ terraform plan -var-file terraform.tfvars.[プロジェクト名]
( + 表記で、クラウド環境に作成されるリソースが表示されるので、内容を確認すること)
$ terraform apply -var-file terraform.tfvars.[プロジェクト名]
(実際に環境を作成するコマンド)
```
apply時に、リソース作成が非同期的に行われ、依存するリソースが作成できないエラーが発生したり、APIの応答自体がエラーになるケースがあるため、api errorによる終了の場合、慌てずに再実行をしてみること。(極力そういったリソースはsleepを挟むように記述しているが、現状全ての問題を回避できているわけではないため、1回の実行でうまく動作せずにエラーになる事が避けられていない)


