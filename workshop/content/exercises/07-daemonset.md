DaemonSetは、全てもしくは一部のNodeで1Podずつ配置するリソースです。簡単なDaemonSetのサンプルを動作させます。まず下記のようなdeployment.yamlを作成します。

```execute
cat manifests/daemonset.yaml
```

kind: ReplicaSetに対するspecは、[Kubernetes API Reference Docs](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.16/#daemonset-v1-apps)に記述があります。

- apiVersion: apiVersionは、DaemonSetというリソースに対するバージョンを指定しています。
- kind: kindは、作成するリソースを指定します。今回はDaemonSetを作成するため、DaemonSetを指定しています。 
- metadataは、作成するリソースに対して名前を設定します。 matadata.nameに、daemonset-containerと名前を指定しています。 
- specは、kindで指定されたリソースに対する具体的な設定をします。今回は、nginxのコンテナイメージを使ったpodということでnginx-pod名前を指定しています。
- spec.selectorは、ReplicaSetが監視を行うPodの情報の設定を行います。
- spec.selector.matchLabelsは、監視対象のPodをkey: valueの形式で指定します。
- spec.templateは、ReplicaSetが複製するPodの情報の設定を行います。
- spec.template.metadataは、ReplicaSetによって監視されるPodの情報の設定を行います
- spec.template.metadata.labelsは、監視対象のPodをkey: valueの形式で設定します。
- spec.containersは、Pod内で起動するコンテナの設定をします。
- spec.containers.nameは、Pod内で起動するコンテナ名を指定します。このnameはPod内でユニークである必要があります。
- spec.containers.imageは、Pod内で起動するコンテナのイメージを指定します。

確認したmanifests/daemonset.yamlマニフェストファイルを利用してDaemonSetリソースを作成します。、kubectl applyコマンドを使用します。また -f オプションでマニフェストファイルを指定します。

```execute
kubectl apply -f daemonset.yaml
```

Podが起動しているかを確認してみます。確認方法は、kubectl get コマンドを実行します。STATUSがRunningとなっていれば正しく起動できています。また、各ノードに1つのPodずつ起動していることが確認できます。

```execute
kubectl get pods -o wide
```
