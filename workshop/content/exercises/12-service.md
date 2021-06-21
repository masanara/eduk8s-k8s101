Serivceによりpodに対するアクセスができることを確認します。通常、Kubernetesクラスター内でPodにアクセスする際はServiceを利用します。Serviceを利用することにより、クラスター内でpodに対するロードバランサーが構成され、クラスター内のDNSにより名前解決が可能になり、PodのIPアドレスを指定することなく名前でアクセスすることが可能になります。

作成済みのDeployment(nginx2)に対するServiceを構成するためのマニフェストを確認します。

```execute
cd $HOME/manifests
cat nginx2-svc.yaml
```

nginx2 podに対するserviceを作成します。

```execute
kubectl apply -f nginx2-svc.yaml
```

作成されたSerfviceを確認します。

```execute
kubectl get service
```

nginx1 podからServiceを介してnginx2 podにアクセスしてみます。


```execute
kubectl exec -it $(kubectl get po -l app=nginx1 -o=jsonpath='{.items[].metadata.name}') -- curl nginx2-svc
```

nginx2 deploymentのrepolica数を2に変更します。

```execute
kubectl scale deploy nginx2 --replicas=2
```

pod数が増えたことを確認します。

```execute
kubectl get pod -o wide
```

nginx2-svcに対するアクセスを繰り返して、異なるnginx2 podに負荷分散されていることを確認します。


```execute
kubectl exec -it $(kubectl get po -l app=nginx1 -o=jsonpath='{.items[].metadata.name}') -- curl nginx2-svc
```

ここまでで、クラスター内のアクセスにServiceを利用することができました。次にクラスター外部からアクセスができるServiceを作成します。クラスターの外部からアクセス可能なServiceは```type: LoadBalancer```として作成します。kubectlコマンドでは以下のようにオプションを付与することでServiceを作成可能です。
```type: LoadBalancer```は外部のロードバランサーと連携し、Serviveを作成すると外部でロードバランサーが構成され、クラスター外部からアクセス可能な仮想IPアドレスが割り当てられます。

```execute
kubectl expose deploy nginx2 --name=nginx2-lb --port=80 --type=LoadBalancer
```

作成されたServieを確認します。nginx2-lbのEXTERNAL-IPが```<pending>```の場合はしばらく待って、何度化確認するとLoadBalancerのIPのアドレスが払い出されます。

```execute
kubectl get service
```

確認したEXTERNAL-IPにアクセスすると、nginx podにアクセスできることが確認できます。
