本ハンズオンでは環境上の理由からdockerのインストールは完了しています。

各ディストリビューション向けのインストール手順は以下のページで詳細に説明されています。

- [https://docs.docker.com/engine/install/](https://docs.docker.com/engine/install/)

##### Ubuntu Linuxへのインストール方法 (本環境で実行しないでください)

必要なパッケージの追加

```
sudo apt-get update && sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
```

GPG鍵のインストール

```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

dockerリポジトリの追加

```
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

docker engineのインストール

```
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
```

dockerユーザーグループへの追加

dockerを利用するためには、dockerユーザーグループに参加している必要があるため自身をdockerユーザーグループに追加します。

```
sudo usermod -aG docker $USER
```

以上でdockerを利用することが可能になります。
