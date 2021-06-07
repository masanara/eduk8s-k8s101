Deploymentは、Podのローリングアップデートやロールバックを実現するリソースです。DeploymentがReplicaSetを管理し、ReplicaSetがPodを管理する3層の親子関係となっています。

manifests/deployment.yamlの内容を確認します。

```execute
cat manifests/deployment.yaml
```

各フィールドについては、次に説明しますが詳細は[こちら](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/deployment-v1/)をご覧ください。

- apiVersion : Deploymentというリソースに対するバージョンを指定しています。
- kind : 作成するリソースを指定します。今回はDeploymentを作成するため、Deploymentを指定しています。
- metadata : 作成するリソースに対して名前の設定します。
  -  matadata.name : 作成したリソースに対する名前を指定します。今回は、nginxのコンテナイメージを使ったpodということでnginxという名前を指定しています。
- specはkindで指定されたリソースに対する具体的な設定を指定します。 
  - spec.strategy : 古いPodを新しいPodに置き換えるための戦略を指定します。
    - spec.strategy.type : RollingUpdateのときには、Podをローリングアップデートで更新します。
    - spec.strategy.rollingUpdate : maxUnavailableとmaxSurgeを指定してローリングアップデートプロセスを制御することができます。
      - spec.strategy.rollingUpdate.maxUnavailable : 更新処理中に利用できないPodの最大数を指定するオプションのフィールドです。値は絶対数もしくはパーセンテージで制>御することができます。 絶対数は、切り捨てによる割合から計算されます。 
      - spec.strategy.rollingUpdate.maxSurge : 0の場合、値は0にできません。デフォルト値は25％です。
      - spec.strategy.rollingUpdate.maxSurgeは、必要な数のPod上に作成できるポッドの最大数を指定するオプションのフィールドです。値は絶対数もしくはパーセンテージで制御することができます。 絶対数は、切り捨てによる割合から計算されます。 
      - spec.strategy.rollingUpdate.maxSurgeが0の場合、値は0にできません。デフォルト値は25％です。
  - spec.replicas : ReplicaSet内でPodの複製数を指定します。今回は3として記述したため3つのPodが複製されます。
  - spec.selector : ReplicaSetが監視を行うPodの情報の設定を行います。
    - spec.selector.matchLabels : 監視対象のPodをkey: valueの形式で指定します。
  - spec.template : ReplicaSetが複製するPodの情報の設定を行います。

# Deploymentの作成

確認したマニフェストファイルからDeploymentを作成してみます。kubectl creatコマンドを実行します。

```execute
kubectl apply -f manifests/deployment.yaml
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

実行結果から、nginxのバージョンが1.20となっていることが確認できます。しかしながら、実際にはこのロールバック機能を使用することは多くありません。ほとんどの場合では、作成されているマニフェストファイルを編集し、kubectl applyコマンドを実行します。動作状態に直接変更を加えてしまうと、構成状況の把握が困難になるためです。
