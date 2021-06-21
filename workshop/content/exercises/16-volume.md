Volumeにはいくつかの種類があります。ボリュームの種類や詳細に関しては[こちら](https://kubernetes.io/docs/concepts/storage/volumes/)を参照してください。

- emptyDir : Podと同じライフサイクルで作成、削除される
- hostPath : Podが起動するホスト上の領域を利用する
- configMap : ConfigMapをVolumeとしてマウントすることが可能
- secret : SecretをVolumeとしてマウントすることが可能
- csi : CSI(Container Storage Interface)を利用して外部のストレージシステムを利用
- nfs : NFSサーバーが公開している領域をVolumeとして利用

### emptyDirの利用

Pod内で複数のコンテナを起動し、Pod間でファイルシステムを共有したい場合、emptyDirと呼ばれるvolumeを利用してデータを共有することが可能です。emptyDir volumeは揮発性があり、Podを削除すると同時に削除されるためデータの永続化はできませんが、Pod内のコンテナ間でデータを共有したい場合などに利用可能です。

まずemptyDirを持たないマルチコンテナPodを作成します。マニフェストを表示します。

```execute
cd $HOME/manifests/volume
cat mc-pod.yaml
```

マニフェストからPodを作成します。

```execute
kubectl create -f mc-pod.yaml
```

Podが起動したことを確認します。mc-podというPodの中でubuntu1とubuntu2というコンテナが起動するため、正常に起動するとREADYが、2/2と表示されます。

```execute
kubectl get pod
```

ubuntu1コンテナ内で、/tmp配下にdateコマンドの結果をファイルとして作成します。


```execute
kubectl exec mc-pod -c ubuntu1 -- /bin/sh -c 'echo `date` > /tmp/date'
```

tmp以下にファイルがあることと、ファイル内にdateコマンドの結果がが記録されていることを確認します。

```execute
kubectl exec mc-pod -c ubuntu1 -- /bin/sh -c 'ls -l /tmp'
kubectl exec mc-pod -c ubuntu1 -- /bin/sh -c 'cat /tmp/date'
```

ubuntu2コンテナで/tmpディレクトリを確認してみます。同じPodではあるものの異なるコンテナであるため、ファイルが存在しません。

```execute
kubectl exec mc-pod -c ubuntu2 -- /bin/sh -c 'ls -l /tmp'
kubectl exec mc-pod -c ubuntu2 -- /bin/sh -c 'cat /tmp/date'
```

次にemptyDirを接続したマニフェストを確認します。このマニフェストではemptyDir volumeをshareという名前で作成し、同じemptyDir volumeをubunt1コンテナでは/mount1、ubuntu2コンテナでは/mount2にマウントしています。2コンテナでは/mount2にマウントしています。

```execute
cat mc-pod-with-vol.yaml
```

emptyDirを利用するpodを作成します。

```execute
kubectl create -f mc-pod-with-vol.yaml
```

mc-pod-with-vol podが起動したことを確認します。

```execute
kubectl get pod
```

ubuntu1コンテナ内で、emptyDirをマウントした/mount配下にdateコマンドの結果をファイルとして作成します。

```execute
kubectl exec mc-pod-with-vol  -c ubuntu1 -- /bin/sh -c 'echo `date` > /mount1/date'
```

/mount以下にファイルがあることと、ファイル内にdateコマンドの結果がが記録されていることを確認します。

```execute
kubectl exec mc-pod-with-vol -c ubuntu1 -- /bin/sh -c 'ls -l /mount1'
kubectl exec mc-pod-with-vol -c ubuntu1 -- /bin/sh -c 'cat /mount1/date'
```

ubuntu2コンテナで/mount2ディレクトリを確認してみます。同じPodでemptyDir volumeを異なるパスにマウントしているので、/mount2配下にdateファイルが存在し、dateコマンドの結果を確認することができます。。

```execute
kubectl exec mc-pod-with-vol -c ubuntu2 -- /bin/sh -c 'ls -l /mount2'
kubectl exec mc-pod-with-vol -c ubuntu2 -- /bin/sh -c 'cat /mount2/date'
```

このセクションで作成したリソースを削除します。

```execute
kubectl delete -f .
```
