#!/bin/bash

# กำหนดสี
RED='\033[0;31m'
GREEN='\033[0;32m'
WARNING='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # ไม่มีสี (reset)

# ตรวจสอบว่า kind ถูกติดตั้งแล้วหรือยัง
if ! command -v kind &> /dev/null
then
    echo -e "${WARNING}\nKind ไม่ได้ถูกติดตั้ง กรุณาติดตั้งก่อน\n${NC}"
    exit 1
fi

# ตรวจสอบว่ามีการระบุชื่อ cluster หรือไม่
CLUSTER_NAME="kind" # ปรับให้ตรงกับชื่อ cluster ที่ต้องการลบ
if [ ! -z "$1" ]; then
    CLUSTER_NAME=$1
fi

# ลบ cluster ด้วย kind
echo "กำลังกำจัด Kind cluster ที่ชื่อ $CLUSTER_NAME..."
kind delete cluster --name "$CLUSTER_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}\nKind cluster ที่ชื่อ $CLUSTER_NAME ถูกลบเรียบร้อยแล้ว\n${NC}"
else
    echo -e "${RED}\nเกิดข้อผิดพลาดในการลบ Kind cluster ที่ชื่อ $CLUSTER_NAME\n${NC}"
    exit 1
fi
