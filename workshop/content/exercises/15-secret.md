Secretはパスワード、OAuthトークン、SSHキーのような機密情報を保存し、管理できるようにします。 Secretに機密情報を保存することは、ConfigMapと同じようにそれらをPodの定義やコンテナイメージに直接記載するより、安全で柔軟です。

ただし、Secretに格納されるデータは暗号化されるわけではなく、base64でエンコードされているだけであるため簡単にデコードすることができてしまいます。マニフェスト群をgit等で管理している場合、Secretをリポジトリに含めないように注意が必要です

機密情報を安全に扱いたい場合は、[HashiCorpのVault](https://learn.hashicorp.com/tutorials/vault/agent-kubernetes)等の利用を検討する必要があります

Secretの作成

```execute
cd $HOME/manifests/secret && cat db-cred.yaml
```

```DB_HOST, DB_USER, DB_PASSWORD``` の値はbase64でエンコードされています。base64でデコードすると各値を取得することが可能です。


```execute
echo bXlzcWw= | base64 -d
echo cm9vdA== | base64 -d
echo cGFzc3dvcmQxMjM= | base64 -d
```

Secretには[8つの種類があります](https://kubernetes.io/ja/docs/concepts/configuration/secret/#secret-types)。種類を指定しない場合、Opaque(geenric)が選択されます。一般的なデータを格納する場合はOpaqueを利用します。


マニフェストを利用してSecretを作成します。

```execute
kubectl creaty -f db-cred.yaml
```

以下のようにkubectllでsecretを作成することも可能です。

```
kubectl create secret generic db-cred --from-literal=DB_HOST=mysql --from-literal=DB_USER=root --from-literal=DB_PASSWORD=password123
```

Secretが作成されたことを確認します。

```execute
kubectl get secret
```


