

nginx1 deploymentを作成します。

```execute
kubectl apply -f manifests/nginx-deploy1.yaml
```

nginx2 deploymentを作成します。

```execute
kubectl apply -f manifests/nginx-deploy2.yaml
```

各マニフェストには[Pod間アンチアフィニティ](https://kubernetes.io/ja/docs/concepts/scheduling-eviction/assign-pod-node/#pod%E9%96%93%E3%82%A2%E3%83%95%E3%82%A3%E3%83%8B%E3%83%86%E3%82%A3%E3%81%A8%E3%82%A2%E3%83%B3%E3%83%81%E3%82%A2%E3%83%95%E3%82%A3%E3%83%8B%E3%83%86%E3%82%A3)を設定してあるため、nginx1 podとnginx2 podは異なるノード上で起動します。

manifest/nginx-deploy1.yamlを確認すると、```.spec.template.spec.affinity``` で ```app=nginx2``` というラベルのPodと同じノードにスケジューリングしない設定が確認できます。

```execute
cat manifests/nginx-deploy1.yaml
```

podの詳細を確認すると、各podが異なるノードで実行されていることが確認できます。

```execute
kubectl get pod -o wide
```

各podの名前をPOD1_NAME/POD2_NAME、IPアドレスをPOD1_IP/POD2_IP 環境変数に設定します。


```execute
POD1_NAME=$(kubectl get pod -o jsonpath='{.items[0].status.podIP}')
POD2_NAME=$(kubectl get pod -o jsonpath='{.items[1].status.podIP}')
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
