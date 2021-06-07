Podとは、コンテナを管理する最小単位のリソースです。Podは1つまたは複数のコンテナで構成されます。Podには仮想NICが割り当てられており、この仮想IPを用いて通信を行います。Pod内に複数のコンテナが存在している場合には、仮想NICが共有され、ローカル・ループバック・アドレスを用いて通信が可能です。

簡単なPodのサンプルを動作させます。k8sは、YAMLやJSONで記述した宣言的なコード（マニフェストファイル）によって、コンテナや周辺リソースを管理します。```manifests/pod.yaml```ファイルの内容を確認します。

```execute
cat manifests/pod.yaml
```

各フィールドについては、次に説明します。Podリソースに関する[こちら](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#pod-v1-core)をご覧ください。

###### マニフェストファイルの解説

- apiVersion : apiVersionは、リソースに対するVersionを設定します。
- kind : kindは、作成するリソースを設定します。今回はPodを作成するため、Podと指定しています。
- metadata : 作成するリソースに対して名前の設定します。
  - matadata.name : 作成するリソースに対する名前を指定します。今回はnginxのコンテナイメージを使ったpodということでnginx-pod名前を指定しています。
- spec : kindで指定されたリソースに対する具体的な設定をします。
  - spec.containers : Pod内で起動するコンテナの設定をします。
  - spec.containers.name : Pod内で起動するコンテナ名を指定します。このnameはPod内でユニークである必要があります。
  - spec.containers.image : Pod内で起動するコンテナのイメージを指定します。 今回は、nginxのコンテナイメージ、バージョン1.20を使用しています。

###### Podの作成と削除

```kubectl create``` コマンドのオプションとして ```-f``` を利用し、manifestsディレクトリに用意されているpod.yamlを指定してPodを作成します。

```execute
kubectl create -f manifests/pod.yaml
```

```kubectl get``` コマンドを実行してPodが起動していることを確認します。STATUSがRunningとなっていれば正しく起動できています。

```execute
kubectl get pods
```

```kubectl delete``` コマンドのオプションとして ```-f``` を利用し、作成時に利用したマニフェストファイルを利用してPodを削除します。

```execute
kubectl delete -f manifests/pod.yaml
```

マニフェストファイルではなく、以下のようにPod名を指定して削除することも可能です。

```
kubectl delete pod nginx-pod
```
