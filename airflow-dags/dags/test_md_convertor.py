from datetime import datetime, timedelta
from airflow import DAG
from airflow.models import Variable
from airflow.operators.python import PythonOperator, BranchPythonOperator
from airflow.providers.amazon.aws.sensors.s3 import S3KeySensor
from airflow.providers.amazon.aws.hooks.s3 import S3Hook
from airflow.utils.trigger_rule import TriggerRule
from airflow.operators.empty import EmptyOperator
import os
import numpy as np

default_args = {
    'owner': 'Chonakan',
    'retries': 5,
    'retry_delay': timedelta(minutes=1)
}

# Variables from Airflow Variable
MINIO_BUCKET_NAME_RAW = Variable.get("bucket_name_raw")
MINIO_BUCKET_NAME_TRANSFORMED = Variable.get("bucket_name_transformed")

# Handling Files path
BASE_LOCAL_PATH = "/usr/local/airflow/include/"
LOCAL_PATH_PDF = BASE_LOCAL_PATH + "course.pdf"
LOCAL_PATH_MD_UPDATE = BASE_LOCAL_PATH + "course_update.md"
LOCAL_PATH_MD_ORIGINAL = BASE_LOCAL_PATH + "course.md"
LOCAL_PATH_DELTA = BASE_LOCAL_PATH + "delta.bsdiff"
BUCKET_FOLDER = "/cpe/"
FILE_KEY_RAW = "course.pdf"
FILE_KEY_TRANSFORMED = "course.md"

# Bucket Connections
S3_CONN_ID = "minio_conn"
s3_hook = S3Hook(aws_conn_id=S3_CONN_ID)

def buckets_connection_checker(**kwargs):
    print("Checking bucket connections")

def is_file_readable(**kwargs):
    # Simulate file readability check
    # Replace this logic with your actual implementation
    if os.path.exists(LOCAL_PATH_PDF):
        return "set_starter_page"
    else:
        return "ocr_operation"

def raw_file_existance_sensor(**kwargs):
    print("Checking raw file existence")

def transformed_file_existance_sensor(**kwargs):
    print("Checking transformed file existence")

def ingest_document(**kwargs):
    print("Ingesting raw document")

def set_starter_page_number(**kwargs):
    x = 10
    y = 2
    z = np.power(x,y)
    print("10^2 = ",z)

def convert_pdf_to_markdown(**kwargs):
    print("Converting PDF to Markdown")

def clean_md_file(**kwargs):
    print("Cleaning Markdown file")

def ingest_transformed_document(**kwargs):
    print("Ingesting transformed document")

def create_delta_file(**kwargs):
    print("Creating delta file")

def md_not_found(**kwargs):
    print("Markdown not found")

def upload_baseline_file(**kwargs):
    print("Uploading baseline file")

def ocr_operation(**kwargs):
    print("Performing OCR")

def generate_binary_delta():
    print("Generate binary delta")

with DAG(
    dag_id='test_md_convertor',
    start_date=datetime(2024, 11, 30),
    schedule_interval='@daily',
    catchup=False,
    default_args=default_args
) as dag:
    
    
    set_starter_page_number1 = PythonOperator(
        task_id='set_starter_page',
        python_callable=set_starter_page_number
    )
    
    convert_pdf_to_markdown1 = PythonOperator(
        task_id='pdf_to_markdown',
        python_callable=convert_pdf_to_markdown
    )

    set_starter_page_number1 >> convert_pdf_to_markdown1