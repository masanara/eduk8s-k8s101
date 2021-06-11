Secretはパスワード、OAuthトークン、SSHキーのような機密情報を保存し、管理できるようにします。 Secretに機密情報を保存することは、ConfigMapと同じようにそれらをPodの定義やコンテナイメージに直接記載するより、安全で柔軟です。

ただし、Secretに格納されるデータは暗号化されるわけではなく、base64でエンコードされているだけであるため簡単にデコードすることができてしまいます。マニフェスト群をgit等で管理している場合、Secretをリポジトリに含めないように注意が必要です

機密情報を安全に扱いたい場合は、[HashiCorpのVault](https://learn.hashicorp.com/tutorials/vault/agent-kubernetes)等の利用を検討する必要があります

Secretの作成

```execute
cd $HOME/manifests/secret && cat db-cred.yaml
```

```DB_Host, DB_User, DB_Password``` の値はbase64でエンコードされています。base64でデコードすると各値を取得することが可能です。


- DB_Hostの値

```execute
echo bXlzcWwtMQ== | base64 -d
```

- DB_Userの値

```execute
echo cm9vdA== | base64 -d
```

- DB_Passwordの値

```execute
echo cGFzc3dvcmQxMjM= | base64 -d
```

Secretには[8つの種類があります](https://kubernetes.io/ja/docs/concepts/configuration/secret/#secret-types)。種類を指定しない場合、Opaque(geenric)が選択されます。一般的なデータを格納する場合はOpaqueを利用します。


マニフェストを利用してSecretを作成します。

```execute
kubectl create -f db-cred.yaml
```

以下のようにkubectllでsecretを作成することも可能です。

```
kubectl create secret generic db-cred --from-literal=DB_Host=mysql --from-literal=DB_User=root --from-literal=DB_Password=password123
```

Secretが作成されたことを確認します。

```execute
kubectl get secret
```

Secretを利用するmysql podを起動します。podを作成するためのマニフェストを確認します。

```execute
cat mysql.yaml
```

このマニフェストでは、SecretのDB_Passwordの値を環境変数MYSQL_ROOT_PASSWORDとして設定するPodをDeploymenとして起動し、mysql-1というServiceによりClusterIPでクラスター内のアクセス可能にします。

```execute
kubectl create -f mysql.yaml
```

Podが起動し、Serviceが作成されたことを確認します。

```execute
kubectl get pod,svc
```

次にデータベースにアクセスするWebアプリケーションをデプロイします。Webアプリケーションは環境変数としてDB_Host, DB_User, DB_Passwordを利用してmysqlに接続確認するだけのシンプルなものです。また、Service(LoadBalancer)により外部からのアクセスを可能にします。マニフェストの内容を確認してみます。


```execute
cat webapp.yaml
```

```.spec.template.spec.containers[].envFrom``` でsecretを参照して内容を管渠変数として設定しています。

マニフェストをデプロイします。

```execute
kubectl apply -f webapp.yaml
```

PodとServiceが作成されたことを確認し、webapp ServiceのEXTERNAL-IPを確認してブラウザでアクセスします。(pendingと表示される場合はしばらく待って再度 ```kubectl get svc``` を実行します。)webappはDBへの接続結果を表示します。画面が緑色になって接続が成功したことを確認します。

```execute
kubectl get pod,svc
```

#### 応用演習

上記の内容ではwebapp, mysqlが共通のSecretを参照しているため正しく接続することが出ています。異なるSecretを利用してwebappを起動し、接続に失敗することを確認してみます。

以下のコマンドでdb-cred1 Secretを新たに作成します。

```
kubectl create secret generic db-cred1 --from-literal=DB_Host=mysql-1 --from-literal=DB_User=root --from-literal=DB_Password=password
```

Webapp Deploymentが参照しているSecretを新しいマニフェストに変更すると、Podが再作成されます。再作成されたPodにLoadBalancer Service経由でアクセスしてMySQLへの接続に失敗することを確認します。

この章の演習が終わったら作成したすべてのリソースを削除します。

```execute
kubectl delete -f $HOME/manifests/secret/
```
