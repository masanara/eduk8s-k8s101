DaemonSetは、全てもしくは一部のNodeで1Podずつ配置するリソースです。簡単なDaemonSetのサンプルを動作させます。まず下記のようなdeployment.yamlを作成します。

```execute
cd $HOME/manifests
cat daemonset.yaml
```

DaemonSetに関する詳細は[こちら](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/daemon-set-v1/)を参照してください。


確認したmanifests/daemonset.yamlマニフェストファイルを利用してDaemonSetリソースを作成します。kubectl applyコマンドを使用します。また -f オプションでマニフェストファイルを指定します。

```execute
kubectl apply -f daemonset.yaml
```


Podが起動しているかを確認してみます。STATUSがRunningとなっていれば正しく起動できています。また、各ノードに1つのPodずつ起動していることが確認できます。(masterノードを除く)

まず現在のノードの構成を確認します。

```execute
kubectl get node -o wide
```

つぎにPodの起動状態を確認します。

```execute
kubectl get pods -o wide
```

作成したDaemonSetリソースを削除します。

```execute
kubectl delete -f daemonset.yaml
```
