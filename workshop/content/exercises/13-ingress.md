ingressリソースのマニフェストテンプレートの内容を確認します。

```execute
cd manifests && cat ingress.yaml
```

```.spec.rules.host[0]``` には、 hostname という値が仮で入っているため、これを環境に合わせて変更します。


```execute
sed -i 's/hostname/{{ session_namespace }}.nginx.{{ ingress_domain }}/g' ingress.yaml
```
```execute
cd $HOME && kubectl create -f manifests/ingress.yaml
```

```execute
kubectl get ingress
```

名前解決はすでに設定されているため、作成されたIngressリソースのFQDNにアクセスして、アクセスできることを確認します。
ブラウザで以下のURLにアクセスし両方のPodにアクセスできていることを確認します。

- [{{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n1]({{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n1)


```execute
kubectl expose deploy nginx1 --port=80 --name=nginx1-svc
```

```execute
kubectl get service
```

ingressリソースのマニフェストテンプレートの内容を確認します。アクセス先(/n1, /n2)に応じて、nginx1-svc、nginx2-svcにアクセス先が変わる設定になっています。

```execute
cd manifests && cat ingress2.yaml
```

```.spec.rules.host[0]``` には、 hostname という値が仮で入っているため、これを環境に合わせて変更します。


```execute
cd manifests
sed -i 's/hostname/{{ session_namespace }}.nginx.{{ ingress_domain }}/g' ingress2.yaml
```

```execute
cd $HOME && kubectl apply -f  manifests/ingress2.yaml
```

ブラウザで以下のURLにアクセスし両方のPodにアクセスできていることを確認します。

- [{{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n1]({{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n1)
- [{{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n2]({{ ingress_protocol }}://{{ session_namespace }}.nginx.{{ ingress_domain }}/n2)
