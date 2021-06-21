Deploymentは、Podのローリングアップデートやロールバックを実現するリソースです。DeploymentがReplicaSetを管理し、ReplicaSetがPodを管理する3層の親子関係となっています。

manifests/deploy.yamlの内容を確認します。

```execute
cd $HOME/manifests && cat deployment.yaml
```

マニフェストの各フィールドの詳細は[こちら](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)をご覧ください。

確認したマニフェストファイルからDeploymentを作成します。kubectl creatコマンドを実行します。

```execute
kubectl apply -f deployment.yaml
```

Podが起動しているかを確認してみます。確認方法は、kubectl get コマンドを実行します。STATUSがRunningとなっていれば正しく起動できています。

```execute
kubectl get pods
```

Deploymentで動作しているコンテナイメージを、nginx:1.20からnginx:1.21にアップデートしてみましょう。

今回は、イメージの更新にkubectl set imageコマンドを実行します。

```execute
kubectl set image deployment deployment-container nginx=quay.io/mnara/nginx:1.21
```

kubectl getコマンドを実行して、Podの状況を確認します。実行結果から、Podの数が4つ動作していることが確認できます。

```execute
kubectl get pods
```

kubectl rollout status コマンドを使用することで、ロールアウトのステータスを確認することができます。たとえば、次のコマンドを実行して、nginx Deployment のロールアウトの状況を確認することができます。

```execute
kubectl rollout status deployment deployment-container
```

次にPodのロールバックを行います。今回は、Deploymentで動作しているコンテナイメージをquay.io/mnara/nginx:1.21から1.20にロールバックします。

ロールバックを行うために、これまでの変更履歴を確認します。 変更履歴は、kubectl rollout historyコマンドを使用します。

CHANGE-CAUSEの部分は、deployment作成時に、 ```--record``` オプションを渡した場合に記載されます。 ```--record``` オプションを用いなかった場合には空になります。

```execute
kubectl rollout history deployment deployment-container
```

ロールバックするには、kubectl rollout undoコマンドを利用します。
引数でrevision番号を指定することができます。

```execute
kubectl rollout undo deployment deployment-container --to-revision 1
```

では、ロールバックができているかを確認します。yamlファイルの内容から、古いバージョンのnginxが動作していることが確認できます。

```
kubectl get $(kubectl get pod -o name | head -n1 ) -o yaml | grep "image: nginx"
```

実行結果から、nginxのバージョンが1.20となっていることが確認できます。しかし、実際にはこのロールバック機能を使用することは多くありません。ほとんどの場合では、作成されているマニフェストファイルを編集し、kubectl applyコマンドを実行します。動作状態に直接変更を加えてしまうと、構成状況の把握が困難になるためです。
