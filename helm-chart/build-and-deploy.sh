#!/bin/bash

# กำหนดสี
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # ไม่มีสี (reset)

# โหลดค่าจากไฟล์ config.env
if [ ! -f "./helm-chart/config.env" ]; then
    echo -e "${RED}\nError: ไม่พบไฟล์ config.env\n${NC}"
    exit 1
fi
source ./helm-chart/config.env

# ตรวจสอบว่า IMAGE_NAME ถูกตั้งค่าหรือไม่
if [ -z "$IMAGE_NAME" ]; then
    echo -e "${RED}\nError: IMAGE_NAME ไม่ถูกกำหนดใน config.env\n${NC}"
    exit 1
fi

# กำหนด IMAGE_TAG เป็น version อัตโนมัติหากตั้งค่าเป็น auto
if [ "$IMAGE_TAG" == "auto" ]; then
    IMAGE_TAG=$(openssl rand -hex 4) # สร้าง string สุ่ม 8 ตัว
fi

# กำหนดค่าพื้นฐานสำหรับ Helm
RELEASE_NAME="airflow"       # ชื่อ Release
NAMESPACE="airflow"          # ชื่อ Namespace
DOCKERFILE_DIR="airflow-dags" # โฟลเดอร์ที่เก็บ Dockerfile
HELM_DIR="helm-chart"

# ตรวจสอบการติดตั้ง Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}\nError: Docker ไม่ได้ติดตั้ง กรุณาติดตั้งก่อน\n${NC}"
    exit 1
fi

# ตรวจสอบการติดตั้ง Helm
if ! command -v helm &> /dev/null; then
    echo -e "${RED}\nError: Helm ไม่ได้ติดตั้ง กรุณาติดตั้งก่อน\n${NC}"
    exit 1
fi

# ตรวจสอบว่า Dockerfile มีอยู่ในโฟลเดอร์ที่กำหนด
if [ ! -f "$DOCKERFILE_DIR/Dockerfile" ]; then
    echo -e "${RED}\nError: Dockerfile ไม่พบในโฟลเดอร์ $DOCKERFILE_DIR\n${NC}"
    exit 1
fi

# เพิ่ม Helm repository สำหรับ Apache Airflow และอัปเดต
echo -e "\nกำลังเพิ่ม Helm repository สำหรับ Apache Airflow...\n"
helm repo add apache-airflow https://airflow.apache.org
helm repo update

# Build Docker Image
echo -e "\nกำลัง Build Docker image: $IMAGE_NAME:$IMAGE_TAG...\n"
docker build -t "$IMAGE_NAME:$IMAGE_TAG" -f "$DOCKERFILE_DIR/Dockerfile" "$DOCKERFILE_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}\nError: เกิดข้อผิดพลาดในการ Build Docker image\n${NC}"
    exit 1
fi
echo -e "${GREEN}\nสำเร็จ: Docker image ถูกสร้างเรียบร้อยแล้ว\n${NC}"

# Load Docker image เข้าไปใน Kind cluster
echo -e "\nกำลังโหลด Docker image เข้าไปใน Kind cluster...\n"
kind load docker-image "$IMAGE_NAME:$IMAGE_TAG"

if [ $? -ne 0 ]; then
    echo -e "${RED}\nError: เกิดข้อผิดพลาดในการโหลด Docker image เข้าไปใน Kind cluster\n${NC}"
    exit 1
fi
echo -e "${GREEN}\nสำเร็จ: Docker image ถูกโหลดเข้าสู่ Kind cluster เรียบร้อยแล้ว\n${NC}"

# สร้าง Namespace หากยังไม่มีอยู่
echo -e "กำลังตรวจสอบ Namespace $NAMESPACE..."
kubectl get namespace $NAMESPACE &> /dev/null
if [ $? -ne 0 ]; then
    echo -e "Namespace $NAMESPACE ไม่พบ กำลังสร้าง..."
    kubectl create namespace $NAMESPACE
    if [ $? -ne 0 ]; then
        echo -e "${RED}\nError: ไม่สามารถสร้าง Namespace $NAMESPACE ได้\n${NC}"
        exit 1
    fi
    echo -e "${GREEN}\nNamespace $NAMESPACE ถูกสร้างเรียบร้อยแล้ว\n${NC}"

    # ติดตั้ง Airflow ด้วย Helm หลังจากสร้าง namespace
    echo -e "\nกำลังติดตั้ง Airflow ด้วย Helm...\n"
    helm install $RELEASE_NAME apache-airflow/airflow --namespace $NAMESPACE
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}\nสำเร็จ: ติดตั้ง Airflow เรียบร้อยแล้ว\n${NC}"
    else
        echo -e "${RED}\nError: ไม่สามารถติดตั้ง Airflow ได้\n${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}\nNamespace $NAMESPACE มีอยู่แล้ว\n${NC}"
fi

# รันคำสั่ง Helm Upgrade โดยไม่ใช้ values.yaml
echo -e "\nกำลังปรับใช้ Airflow ด้วย Helm...\n"
helm upgrade $RELEASE_NAME apache-airflow/airflow \
    --namespace $NAMESPACE \
    --set images.airflow.repository="$IMAGE_NAME" \
    --set images.airflow.tag="$IMAGE_TAG" \
    --set webserver.defaultUser.username=admin \
    --set webserver.defaultUser.password=admin \
    --set executor=CeleryExecutor \
    --debug 2> $HELM_DIR/helm_debug.log

# แสดง debug ชั่วคราว
# cat helm_debug.log

# ตรวจสอบสถานะ
if [ $? -eq 0 ]; then
    # ลบส่วน debug ออก
    # tput cuu "$(wc -l < $HELM_DIR/helm_debug.log)" && tput ed
    echo -e "${GREEN}\nสำเร็จ: ปรับใช้ Airflow สำเร็จ!\n${NC}"
    # ลบไฟล์ log ชั่วคราว
    # rm helm_debug.log
else
    echo -e "${RED}\nError: เกิดข้อผิดพลาดในการปรับใช้ Airflow\n${NC}"
    exit 1
fi