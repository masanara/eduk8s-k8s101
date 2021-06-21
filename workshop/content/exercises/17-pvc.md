Pod内で生成されたデータを永続化するためにはPersistentVolume(PV)を利用します。PVリソースはクラスターワイドなリソースであり、以下のようなマニフェストにより外部で提供されたボリュームをPVとして定義することで利用可能になります。

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: block-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  persistentVolumeReclaimPolicy: Retain
  fc:
    targetWWNs: ["50060e801049cfd1"]
    lun: 0
    readOnly: false
```

PVリソースが定義されると、PodからPersitentVolumeClaim(PVC)と呼ばれるリソースを介して、要件にあったPVをPodに接続して利用することが可能です。Podとは異なるライフサイクルでVolumeを管理することが可能になり、データの永続化が可能になります。

PVCは以下のようなマニフェストとなります。必要とされるVolumeの要件が指定されているため、PVの中で条件をみたすVolumeが選択されます。

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: block-pvc
spec:
  accessModes:
    - ReadWriteOnce
  volumeMode: Block
  resources:
    requests:
      storage: 10Gi
```

ただしこのような方法では、管理者が事前にいくつものVolumeを設定しておく必要があり、運用が煩雑となるためPVCの内容に応じて、必要なPVが動的に構成されるDynamic Volume Provisioning(動的プロビジョニング)を利用することが一般的です。動的プロビジョニングはストレージプロバイダー側で実装され、StorageClass APIにより提供されます。

ここでは、動的プロビジョニングに対応したStorageClassを利用して動的にPVを作成し、Podから利用する方法を確認します。

StorageClassリソースが定義されており、```default```として設定されていることを確認します。PVCリソースでStorageClassを明示的に指定しない場合、defaultとして設定されていStorageClassが自動的に選択されます。

```execute
kubectl get storageclass
```

PVCリソースを定義するマニフェストを確認します。このマニフェストでは```data-volume```という名前でPVCを作成し、1Giの容量のPVを要求します。accessModesとして指定している```ReadWriteOnce```は1つのPodからのみReadWrite可能なPVであることを示しています。

```execute
cd $HOME/manifests/pvc && cat pvc.yaml
```

マニフェストファイルを利用してPVCを作成します。

```execute
kubectl apply -f pvc.yaml
```

PVCが作成されたことを確認します。CAPACITYは1Giとなっており、STORAGECLASSとして上記で確認したdefaultのStorageClassが利用されていることが確認できます。

```execute
kubectl get pvc
```

PVが作成されていることを確認します。PVはクラスターレベルのリソースであるため、grepで自身の作成したPVのみ表示しています。RECLAIM POLICYがDeleteとなっているため、PVCを削除するとPVも削除されます。

```execute
kubectl get pv | grep $SESSION_NAME
```

PVCを利用するPodのマニフェストを確認します。このマニフェストでは作成したPVCをdataという名前のVolumeとして利用し、nginx podの/usr/share/nginx/htmlにマウントしています。また、アクセスが確認できるようtepe: LoadBalanceのServiceを作成しています。

```execute
cat pod-with-pvc.yaml
```

マニフェストを利用してPodを作成します。

```execute
kubectl create -f pod-with-pvc.yaml
```

PodとServiceが作成されたことを確認します。


```execute
kubectl get pod,service
````

nginxのhtmlディレクトリである /usr/share/nginx/html の中身を確認します。PVCで動的にプロビジョニングしたPVをマウントしているため、中身は空になっています。(ブロックとして接続しているため lost+found ディレクトリが存在します)

```execute
kubectl exec nginx-pod -- sh -c 'ls -l /usr/share/nginx/html'
```

ServiceのEXTERNAL-IPを確認してブラウザでアクセスします。/usr/share/nginx/html配下にファイルがないため、403 Forbiddenとなります。

```execute
kubectl get svc
```

dateコマンドの結果をindex.htmlとして保存します。

```execute
kubectl exec nginx-pod -- sh -c 'date > /usr/share/nginx/html/index.html'
```

ブラウザで再度EXTERNAL-IPにアクセスすると、dateコマンドの出力結果を確認することが可能です。

nginx podを削除します。

```execute
kubectl delete -f pod-with-pvc.yaml --force
```

pvcは削除されずに残っていることを確認します。

```execute
kubectl get pvc
```

同じマニフェストでpodを再作成して、serviceのEXTERNAL-IPを確認します。

```execute
kubectl apply -f pod-with-pvc.yaml
kubectl get pod,svc
```

ブラウザでEXTERNAL-IPにアクセスすると、前回アクセスしたときと同じdateコマンドの出力結果が表示されます。Podを削除しても、PV上のデータが永続化されているためです。


このセクションで作成したリソースを削除します。

```execute
kubectl delete -f .
```
