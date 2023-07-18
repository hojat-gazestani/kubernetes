
```shell
kubectl get storageclasses

kubectl apply -f local-path-storage.yaml

kubectl get pods -n local-path-storage
```

```shell
- create a new storage class that uses rancher

vim sc.yaml

kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: fast
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer


kubectl apply -f sc.yaml
```

```shell
kubectl get storageclasses

vim pvc.yaml
spec:
  template:
    spec:
      containers:
        - name: mysql
          volumeMounts:
            - name: data
              mountPath: /var/lib/mysql
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: your-pvc-name
  storageClassName: fast
```

```shell
kubectl apply -f pvc.yaml
kubectl get pvc
kubectl describe pvc your-pvc-name
```