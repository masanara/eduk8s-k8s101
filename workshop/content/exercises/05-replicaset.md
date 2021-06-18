ReplicaSetとは指定した数のPodを起動し、その数を維持し続けるリソースです。Worker Nodeの障害などの理由によってPodが停止した場合には、ReplicaSetが他のNodeでPodの再起動を行います。
ReplicaSetのマニフェストは以下のような記述になります。 ```.spec.replicas``` として起動するPodの数を指定し、Podのスペックを ```.spec.template``` 配下に記述します。

```execute
cd $HOME/manifests
cat replicaset.yaml
```

ReplicaSetマニフェストのspecは、[こちら](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/replica-set-v1/)を御覧ください。

```execute
kubectl create  -f replicaset.yaml
```

Podが起動しているかを確認してみます。確認方法は、kubectl get コマンドを実行します。今回は、-o wide オプションを使用して詳細情報を出力しています。STATUSがRunningとなっていれば正しく起動できています。

```execute
kubectl get pods -o wide
```

ReplicaSetの設定を変更して、Podの数をスケーリングしてみましょう。Podスケーリング方法は、次の2つがあります。

- マニフェストファイルを編集し、kubectl apply コマンドを実行する
- kubectl scale コマンドを実行する

今回はkubectl scale コマンドを使用してスケールさせてみます。

```execute
kubectl scale rs nginx-replica --replicas 5
```

Podがスケールされているかを確認します。Podの数が5つに増えていることが確認できます。

```execute
kubectl get pods -o wide
```

次にセルフヒーリングの機能をみてみましょう。

セルフヒーリングはKubernetesにおける重要なコンセプトの一つで、Nodeの障害時にもサービス断を防ぐしくみです。

今回は、試しに1つのPodを削除してみましょう。(kubectl get podの結果で一番上に表示されるものを削除します)

```execute
kubectl delete $(kubectl get pod -o name | head -n1)
```

再度確認すると新しいPodが作成されていることが分かります。(新しく作成されたPodだけAGEが短くなっていることが確認できます。)

```execute
kubectl get pods -o wide
```

最後に作成した作成したリソースを削除します。

```execute
kubectl delete -f replicaset.yaml
```

#### apiVersionに関して
全てのk8sのリソースには、API Versionがあります。k8sのAPIは、いくつかのグループによって構成されており、"グループに属する場合"と"属さない場合"よってapiVersionの書き方が異なります。それぞれのオブジェクトでは、以下のように構成されます。

- APIグループに属している場合: apiVersion: ***APIGROUP***/***GROUPVERSION***
- APIGROUPに属していない場合: apiVersion: v1

前節で紹介したpodに対しては、APIGROUPが空白となっています。これは、"グループに属さない"ことを示しています。 対して、replicasetsは、APIGROUPが"apps"と"extensions"なっています。"appsとextensionsいうグループに属す"ことを示してます。なぜ2つのグループに属しているかというと、移行期のため2つのバージョンが存在しているためです。

apiVersion対応はkubectl api-resourcesコマンドを実行することで確認することができます。

```
 $ kubectl api-resources | grep -e replicaset -e pods -e NAME
NAME                              SHORTNAMES   APIGROUP                       NAMESPACED   KIND
pods                              po                                          true         Pod
replicasets                       rs           apps                           true         ReplicaSet
podsecuritypolicies               psp          extensions                     false        PodSecurityPolicy
replicasets                       rs           extensions                     true         ReplicaSet
podsecuritypolicies               psp          policy                         false        PodSecurityPolicy
```

