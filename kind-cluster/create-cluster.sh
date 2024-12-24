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
    echo -e "Kind ไม่ได้ถูกติดตั้ง กรุณาติดตั้งก่อน\n${NC}"
    exit 1
fi

# ชื่อไฟล์ configuration
CONFIG_FILE="./kind-cluster/kind-cluster.yaml"

# ตรวจสอบว่าไฟล์ configuration มีอยู่หรือไม่
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${WARNING}\nไม่พบไฟล์ $CONFIG_FILE \n${NC}"
    exit 1
fi

# สร้าง cluster ด้วย kind
echo "กำลังสร้าง Kind cluster ด้วยไฟล์ $CONFIG_FILE..."
kind create cluster --config "$CONFIG_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}\nKind cluster ถูกสร้างเรียบร้อยแล้ว\n${NC}"
else
    echo -e "${RED}\nเกิดข้อผิดพลาดในการสร้าง Kind cluster\n${NC}"
    exit 1
fi
