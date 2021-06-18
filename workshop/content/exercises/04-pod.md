Podとは、コンテナを管理する最小単位のリソースです。Podは1つまたは複数のコンテナで構成されます。Podには仮想NICが割り当てられており、この仮想IPを用いて通信を行います。Pod内に複数のコンテナが存在している場合には、仮想NICが共有され、ローカル・ループバック・アドレスを用いて通信が可能です。

簡単なPodのサンプルを動作させます。k8sは、YAMLやJSONで記述した宣言的なコード（マニフェストファイル）によって、コンテナや周辺リソースを管理します。```manifests/pod.yaml```ファイルの内容を確認します。

```execute
cd $HOME/manifests
cat pod.yaml
```

Podマニフェストの詳細は[こちら](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)をご覧ください。

###### Podの作成と削除

```kubectl create``` コマンドのオプションとして ```-f``` を利用し、manifestsディレクトリに用意されているpod.yamlを指定してPodを作成します。

```execute
kubectl create -f pod.yaml
```

```kubectl get``` コマンドを実行してPodが起動していることを確認します。STATUSがRunningとなっていれば正しく起動できています。

```execute
kubectl get pods
```

```kubectl delete``` コマンドのオプションとして ```-f``` を利用し、作成時に利用したマニフェストファイルを利用してPodを削除します。

```execute
kubectl delete -f pod.yaml
```

マニフェストファイルではなく、以下のようにPod名を指定して削除することも可能です。

```
kubectl delete pod nginx-pod
```
