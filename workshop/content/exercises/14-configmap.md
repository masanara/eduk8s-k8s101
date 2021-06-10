ConfigMapリソースを利用すことにより様々な設定をコンテナ起動時に利用する事が可能になります。気密性の内データをキーと値のペアで保存することが可能です。Podは環境変数、コマンドライン引数、またはボリューム内の設定ファイルとしてConfigMapを利用できます。

ConfigMapリソースを利用することで、環境固有の設定をコンテナイメージから分離できるため、アプリケーションを簡単に移植することが可能になります。


ConfigMapリソースを作成します。

```execute
cd $HOME/manifests/configmap && cat message.yaml
```

kubectlコマンドでマニフェストを利用してConfigMapを作成します。

```execute
kubectl apply -f message.yaml
```

以下のようにkubectlの引数としてConfigMapを作成することも可能です。


```
kubectl create configmap message --from-literal=MESSAGE='hello, world!'
```

ConfigMapが作成されたことを確認します。

```execute
kubectl get configmap
```

ConfigMapを利用するPodを作成します。マニフェストを確認します。

```execute
cat cm-env.yaml
```

このマニフェストでは、ubuntuイメージを利用して起動後に ```sleep 3600``` を実行するだけのシンプルなPodを作成します。 ```envFrom``` としてConfigMapを参照しているため、環境変数としてConfigMapの内容を環境変数として参照することが可能です。

```execute
kubectl create -f cm-env.yaml
```

Pod内の環境変数 ```${MESSAGE}``` がConfigMapに指定した文字列であることを確認します。

```execute
kubectl exec cm-env -- bash -c 'echo ${MESSAGE}'
```

kubectl patchコマンドでConfigMapのデータを変更します。

```execute
kubectl patch cm message -p '{"data":{"MESSAGE": "HELLO, WORLD!"}}'
```

ConfigMapの変更はすぐに反映されますが、Podは起動時にConfigMapを参照するため、新しいConfigMapは反映されません。新しいConfigMapを利用するにはPodを再作成します。

```execute
kubectl delete -f cm-env.yaml --force --grace-period=0
```

Podを再度作製します。

```execute
kubectl create -f cm-env.yaml
```

Podが新しいConfigMapを利用して起動するため、```${MESSAGE}```環境変数は新しい値(HELL, WORLD!)と表示されます。


```execute
kubectl exec cm-env -- bash -c 'echo ${MESSAGE}'
```

ConfigMapは環境変数としてPodから利用するだけでなく、ファイルとして参照することも可能です。ファイルとして利用することによりコンテナ内で起動するアプリケーションの設定ファイルをConfigMapとして構成することが可能です。

ConfigMapをVolumeとして利用するPodを作製してみます。message ConfigMapを```/etc/config```にマウントするマニフェストを確認します。

```execute
cat cm-vol.yaml
````

Podを作成します。

```execute
kubectl create -f cm-vol.yaml
```

Podが起動したことを確認します。

```execute
kubectl get pod
```

作成したcm-vol Pod内の/etc/config/MESSAGEファイルが作成されており、内容を確認するとConfigMapで指定したメッセージが表示されます。

```execute
kubectl exec cm-vol -- bash -c 'cat /etc/config/MESSAGE'
```

最後にモジュールで作成したリソースをすべて削除します。

```execute
kubectl delete -f . --force --grace-period=0
```

