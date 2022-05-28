<img height="120px" align="right" alt="CSI SSHFS" src="https://raw.githubusercontent.com/robin-rpr/csi-sshfs/master/csi-sshfs.svg" title="csi-sshfs"/>

# Kubernetes CSI Driver for SSHFS

Mount directories in Kubernetes using a SSH Connection

---

## Installation

Deploy the whole Directory `manifests`.
This installs the CSI Controller and Node Plugin and a appropriate Storage Class for the Driver.

```bash
git clone git@github.com:robin-rpr/csi-sshfs.git && \
  kubectl apply -f csi-sshfs/manifests
```

## Usage
To use the CSI Driver create a `PersistentVolume` and `PersistentVolumeClaim` like the Example one:
```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: data-sshfs
  labels:
    name: data-sshfs
spec:
  accessModes:
  - ReadWriteMany
  capacity:
    storage: 100Gi
  storageClassName: sshfs
  csi:
    driver: csi-sshfs
    volumeHandle: data-id
    volumeAttributes:
      server: "<HOSTNAME|IP>"
      port: "22"
      share: "<PATH_TO_SHARE>"
      privateKey: "<NAMESPACE>/<SECRET_NAME>"
      user: "<SSH_CONNECT_USERNAME>"
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-sshfs
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
  storageClassName: sshfs
  selector:
    matchLabels:
      name: data-sshfs
```

Next add your private SSH Keys as Secret:
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: example
  namespace: default
type: kubernetes.io/ssh-auth
data:
  ssh-privatekey: # add your SSH-Private Key base64 encoded
```

Then mount the Volume into a Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx 
spec:
  containers:
  - image: maersk/nginx
    imagePullPolicy: Always
    name: nginx
    ports:
    - containerPort: 80
      protocol: TCP
    volumeMounts:
      - mountPath: /var/www
        name: data-sshfs
  volumes:
  - name: data-sshfs
    persistentVolumeClaim:
      claimName: data-sshfs
```

### You are all set 🎉 
[Not working?](https://github.com/robin-rpr/csi-sshfs/issues)

