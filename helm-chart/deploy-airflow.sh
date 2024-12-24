#!/bin/bash

# กำหนดค่าพื้นฐาน
RELEASE_NAME="airflow"      # ชื่อ Release
NAMESPACE="airflow"         # ชื่อ Namespace
VALUES_FILE="values.yaml"   # ไฟล์ค่าคอนฟิก

# ตรวจสอบว่าไฟล์ values.yaml มีอยู่หรือไม่
if [ ! -f "$VALUES_FILE" ]; then
    echo "Error: $VALUES_FILE ไม่พบในไดเรกทอรีปัจจุบัน"
    exit 1
fi

# รันคำสั่ง Helm Upgrade
echo "กำลังปรับใช้ Airflow ด้วย Helm..."
helm upgrade --install $RELEASE_NAME apache-airflow/airflow \
    --namespace $NAMESPACE \
    -f $VALUES_FILE \
    --debug

# ตรวจสอบผลลัพธ์
if [ $? -eq 0 ]; then
    echo "ปรับใช้ Airflow สำเร็จ!"
else
    echo "เกิดข้อผิดพลาดในการปรับใช้ Airflow"
    exit 1
fi
