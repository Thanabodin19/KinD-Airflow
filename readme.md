# Airflow on KinD Cluster 

## Install KinD (Kubernetes in Docker) 🪼
On macOS via Homebrew
```bash
brew install kind
```

## Install Helm 📃
On macOS via Homebrew
```bash
brew install helm
```

## Install K9s 🐶
Moniter
On macOS via Homebrew
```bash
brew install k9s
```

## Create KinD Cluster 🐳 

Run Scrept Create-Cluster.sh
```bash
./kind-cluster/create-cluster.sh
```
> [!NOTE]  
> ถ้าเกิดไม่สามารถ Execute file create-cluster.sh ได้ใช้คำสั่งนี้
> ```bash
> sudo chmod +x ./kind-cluster/create-cluster.sh

<!-- ## Deploy AirFlow On KinD Cluster (Server)
### User Helm Chart
```bash
./helm-chart/deploy-airflow.sh
```
> [!NOTE]  
> ถ้าเกิดไม่สามารถ Execute file deploy-airflow.shได้ใช้คำสั่งนี้
> ```bash
> sudo chmod +x ./helm-chart/create-kind-cluster.sh

> [!WARNING]  
> อยากลืมเปลี่ยน repository และ tag ตาม Contrainer ที่เราจะ Deploy -->

## Bluid Image And Deploy AirFlow On KinD Cluster ⚒️ ⌛
```bash
./helm-chart/build-and-deploy.sh
```
> [!NOTE]  
> ถ้าเกิดไม่สามารถ Execute file deploy-airflow.shได้ใช้คำสั่งนี้
> ```bash
> sudo chmod +x ./helm-chart/build-and-deploy.sh

> [!WARNING]    
> ถ้ามี Error แบบนี้ 
> ```bash
>- ERROR: command "docker save -o /tmp/images-tar1798079270/images.tar airflow-dags:38e61f8d" failed with error: exit status 1 
>
>- Command Output: failed to save image: invalid output path: directory "/tmp/images-tar1798079270" does not exist
>```
> ใช้คำสั่งนี้ TMPDIR=<path เก็บ images>
>```bash
>export TMPDIR=/home/s6410301026/temp

### Forward port server to local
```bash
ssh -L localhost:<port>:localhost:<port> <server>
```


## Delete AirFlow Helm Chart 📈
```bash
./helm-chart/delete-airflow.sh
```
> [!NOTE]  
> ถ้าเกิดไม่สามารถ Execute file deploy-airflow.shได้ใช้คำสั่งนี้
> ```bash
> sudo chmod +x ./helm-chart/delete-airflow.sh

## Delete KinD Cluster 🔪
```bash
./kind-cluster/delete-kind-cluster.sh
```
> [!NOTE]  
> ถ้าเกิดไม่สามารถ Execute file delete-kind-cluster.sh ได้ใช้คำสั่งนี้
> ```bash
> sudo chmod +x ./kind-cluster/delete-kind-cluster.sh