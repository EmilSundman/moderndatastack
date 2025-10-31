FROM python:3.10-slim

# Arguments & Environment variables
ENV DAGSTER_HOME=/opt/dagster/dagster_home
ENV DAGSTER_CWD=/opt/dagster/app
ARG DBT_PROJECT_NAME=dbt-core
ARG DBT_PROJECT_DIR=${DAGSTER_CWD}/location_dbt_layer
ARG DBT_PROFILES_DIR=${DAGSTER_CWD}/location_dbt_layer
ARG DBT_COMPILE_TARGET=duckdb_dev
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Set the working directory during build phase
WORKDIR ${DAGSTER_CWD}

RUN mkdir -p $DAGSTER_HOME

# Install dependencies
RUN apt-get update && apt-get install -y build-essential curl
RUN python -m pip install uv

# Set virtual environment and install requirements
COPY platform/dbt/requirements.txt ${DBT_PROJECT_DIR}/requirements.txt 
RUN uv pip install --system --no-cache -r ${DBT_PROJECT_DIR}/requirements.txt 

# Copy code into the container
COPY platform/dagster ${DAGSTER_CWD}/dagster-core
COPY platform/dbt ${DBT_PROJECT_DIR}

# Create database directory and initialize empty database file for build-time compilation
RUN mkdir -p /opt/dagster/app/db


# Set the working directory
WORKDIR ${DBT_PROJECT_DIR}

# Compile project
RUN dbt compile --target ${DBT_COMPILE_TARGET}

EXPOSE 1001

# Expose Dagster API port
CMD ["dagster", "code-server", "start", "-f", "./definitions.py", "-h", "0.0.0.0", "-p", "1001"]