k8sでコンテナを動かすためには、以下の機能について理解する必要があります。

- Pod: コンテナを管理する最小単位
- ReplicaSet: 指定したPodの数の起動を維持する
- Deployment: Podのローリングアップデートなどを行う
- DaemonSet: 全てのnodeに1podの起動を維持する
- StatefulSet: Podの起動順序の制御などを行う
- Job: 一度限りの実行処理を行う
- CronJob: 定期実行処理を行う

各機能については、次のような図で表すことができます。

詳細は各章で紹介しますが、それぞれの機能が親子関係になっています。

例えば、Deploymentを例にとりますが、DeploymentがReplicasetを管理し、ReplicaSetがPodを管理する3層の親子関係になっています。

この親子関係は、k8sを理解するうえで非常に重要な概念となります。

各機能を理解するとともに合わせて意識しておく必要があります。

![file](images/resources.png)

##### Pod

Podとは、コンテナを管理する最小単位のリソースです。

Podは1つまたは複数のコンテナで構成されます。

Podには仮想NICが割り当てられており、この仮想IPを用いて通信を行います。

Pod内に複数のコンテナが存在している場合には、仮想NICが共有され、ローカル・ループバック・アドレスを用いて通信が可能です。

###### Podの作成
簡単なPodのサンプルを動作させます。k8sは、YAMLやJSONで記述した宣言的なコード（マニフェストファイル）によって、コンテナや周辺リソースを管理します。Podも同様に、下記のようなマニフェストファイルを作成して管理できます。本マニフェストファイルは、Pod内に一つのコンテナを作成します。

```yml
apiVersion: v1
kind: Pod
metadata:
  name: nginx-pod
spec:
  containers:
    - name: nginx
      image: quay.io/mnara/nginx:latest
```

```execute
kubectl apply -f manifests/pod.yaml
```

各フィールドについては、次に説明します。
詳細は[こちら](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#pod-v1-core)をご覧ください。

###### マニフェストファイルの解説

####### apiVersion  

apiVersionは、リソースに対するVersionを設定します。

今回のマニフェストファイルでは、2行目に記載されている、Podというリソースに対するバージョンを指定しています。

## kind

kindは、作成するリソースを設定します。

今回はPodを作成するため、Podと指定しています。

## metadata

metadataは、作成するリソースに対して名前の設定します。

matadata.nameでは、作成したリソースに対する名前を指定します。

今回は、nginxのコンテナイメージを使ったpodということでnginx-pod名前を指定しています。

## spec

specは、kindで指定されたリソースに対する具体的な設定をします。

kind: Podに対するspecは、[Kubernetes API Reference Docs](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#podspec-v1-core)に記述がある。

spec.containersは、Pod内で起動するコンテナの設定をします。

spec.containers.nameは、Pod内で起動するコンテナ名を指定します。このnameはPod内でユニークである必要があります。

spec.containers.imageは、Pod内で起動するコンテナのイメージを指定します。

今回は、nginxのコンテナイメージ、バージョン1.16を使用しています。

# Podの作成と削除

マニフェストファイルからPodを作成する。

pod.yaml という名前でファイルに保存し、マニフェストファイルを実行します。

実行方法は、kubectl applyコマンドを使用する。

また -f オプションでマニフェストファイルを指定します。

```bash
$ kubectl apply -f pod.yaml
pod/pod created
```

Podが起動しているかを確認する。

確認方法は、kubectl get コマンドを実行します。

STATUSがRunningとなっていれば正しく起動できています。

```bash
$ kubectl get pods
NAME             READY   STATUS    RESTARTS   AGE
pod   1/1     Running   0          14m
```
では、次に作成したPodを削除します。

削除方法は、kubectl delete コマンドを実行します。
また -f オプションでマニフェストファイルを指定します。

```bash
$ kubectl delete -f pod.yaml
pod "pod" deleted
```


