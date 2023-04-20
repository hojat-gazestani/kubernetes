# 

* Install ingress Controller in minikube
```bash
minikube addons enable ingress
```

* Verify
```bash
kubectl get pod -n kube-system
nginx-ingress-controller
```

Create ingress rule
```bash
kubectlget ns
# kubernetes-dashboard
```

Access to the dashboard web
```bash
kubectl get all -n kubernetes-dashboard
service/kubernetes-dashboard	ClusterIP	1.1.1.1
```

* Create an ingress to access to kubernetes dashboard
```bash
vim dashboard-ingress.yaml
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
	name: dashboard-ingress
	namespace: kub
spec:
	rules:
	- host: dashboard.com
	  http:
	  	paths:
	  	- backend:
	  	  serviceName: kubernetes-dashboard
	  	  servicePort: 80
```

* Create dashboard
```bash
kubectl apply -f dashboard-ingress.yaml
kubectl get ingress -n kubernetes-dashboard --watch

```

* Ingress default backend
```bash
kubectl describe ingress dashboard-ingress -n kubernetes-dashboard
# Default backend: default-http-backend: 80
```

* Multiple path for same host
```bash

apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: simple-fanout-example
  annotations:
    nginx-ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: my-app
    http:
      paths:
      - path: /analytics
      	backend:
      	  serviceName: analytics-service
      	  servicePort: 3000
      - path: /shopping
      	backend:
      	  serviceName: shopping-service
      	  servicePort: 8000
```

* Multi sub-domains or domains
```bash
vim
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: name-virtual-host-ingress
spec:
  rules:
  - host: analytics.mypp.com
    http:
      paths:
        backend:
          serviceName: analytics-service
          servicePort: 3000
  - host: shopping.mypp.com
    http:
      paths:
        backend:
          serviceName: shopping-service
          servicePort: 8000
```

* Configuring TLS Certificate - https//
```bash
vim
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  rules:
    - host: myapp.com
      http:
        paths:
        - path: /
          backend:
            serviceName: myapp-internal-service
            servicePort: 8080


vim 
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: tls-example-ingress
spec:
  tls:
  - hosts:
    - myapp.com
    secretName: myapp-secret-tls
  rules:
    - host: myapp.com
      http:
        paths:
        - path: /
          backend: 
          serviceName: myapp-internal-service
          servicePort: 8080

vim 
apiVersion: v1
kind: Secret
metadata:
  name: myapp-secret-tls
  namespace: default
data:
  tls.crt: base64 encoded cert
  tls.key: base64 encoded key
type: kubernetes.io/tls

```