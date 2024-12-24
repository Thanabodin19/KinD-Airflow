FROM apache/airflow
# COPY . .
COPY /dags ./dags
COPY requirements.txt requirements.txt

RUN pip3 install -r requirements.txt

USER airflow
