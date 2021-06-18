pod間の通信を確認します。

pod間通信は[CNI(Container Network Interface)](https://kubernetes.io/ja/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)によって実現されています。本環境では[Antrea](https://antrea.io/)を利用しており、各ノードにはpod向けCIDRが割り当てられています。各ノードのpodCIDRは以下のコマンドで確認可能です。

マニフェストディレクトリに移動します。

```execute
cd $HOME/manifests
```

nginx1 deploymentを作成します。

```execute
kubectl apply -f nginx-deploy1.yaml
```

nginx2 deploymentを作成します。

```execute
kubectl apply -f nginx-deploy2.yaml
```

各マニフェストには[Pod間アンチアフィニティ](https://kubernetes.io/ja/docs/concepts/scheduling-eviction/assign-pod-node/#pod%E9%96%93%E3%82%A2%E3%83%95%E3%82%A3%E3%83%8B%E3%83%86%E3%82%A3%E3%81%A8%E3%82%A2%E3%83%B3%E3%83%81%E3%82%A2%E3%83%95%E3%82%A3%E3%83%8B%E3%83%86%E3%82%A3)を設定してあるため、nginx1 podとnginx2 podは異なるノード上で起動します。

manifest/nginx-deploy1.yamlを確認すると、```.spec.template.spec.affinity``` で ```app=nginx2``` というラベルのPodと同じノードにスケジューリングしない設定が確認できます。

```execute
cat nginx-deploy1.yaml
```

podの詳細を確認すると、各podが異なるノードで実行されていることが確認できます。

```execute
kubectl get pod -o wide
```


```execute
kubectl get node -o custom-columns=NAME:.metadata.name,podCIDR:.spec.podCIDR
```

各podの名前をPOD1_NAME/POD2_NAME、IPアドレスをPOD1_IP/POD2_IP 環境変数に設定します。


```execute
POD1_NAME=$(kubectl get pod -o jsonpath='{.items[0].metadata.name}')
POD2_NAME=$(kubectl get pod -o jsonpath='{.items[1].metadata.name}')
POD1_IP=$(kubectl get pod -o jsonpath='{.items[0].status.podIP}')
POD2_IP=$(kubectl get pod -o jsonpath='{.items[1].status.podIP}')
echo POD1 $POD1_NAME $POD1_IP
echo POD2 $POD2_NAME $POD2_IP
```

POD1からpingコマンドでPOD2への疎通を確認します。

```execute
kubectl exec -it $POD1_NAME -- ping -c 2 ${POD2_IP}
```

POD2からpingコマンドでPOD1への疎通を確認します。

```execute
kubectl exec -it $POD2_NAME -- ping -c 2 ${POD1_IP}
```

異なるノード上で起動するPOD1 - POD2 間で通常の通信ができています。各ノードの間でオーバーレイネットワークが構成されており、ノードを跨ぐPodどうしの通信がはノードでカプセル化され、別ノードにパケットが転送され、カプセル化を解いて宛先podにパケットを届けています。
