#!/bin/bash

# กำหนดสี
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # ไม่มีสี (reset)

# กำหนดค่าพื้นฐาน
RELEASE_NAME="airflow"  # ชื่อ Release
NAMESPACE="airflow"     # ชื่อ Namespace

# ลบ Release ด้วย Helm
echo "กำลังลบ Airflow Release ด้วย Helm..."
helm uninstall $RELEASE_NAME --namespace $NAMESPACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}\nRelease $RELEASE_NAME ถูกลบสำเร็จ\n${NC}"
else
    echo -e "${RED}\nError: เกิดข้อผิดพลาดในการลบ Release $RELEASE_NAME \n${NC}"
    exit 1
fi

# ลบ Namespace หากไม่มีการใช้งานอื่น ๆ
echo "กำลังลบ Namespace $NAMESPACE..."
kubectl delete namespace $NAMESPACE

if [ $? -eq 0 ]; then
    echo -e "${GREEN}\nNamespace $NAMESPACE ถูกลบสำเร็จ\n${NC}"
else
    echo -e "${RED}\nError: เกิดข้อผิดพลาดในการลบ Namespace $NAMESPACE\n${NC}"
    exit 1
fi

echo -e "${GREEN}การลบ Airflow เสร็จสิ้น\n${NC}"
