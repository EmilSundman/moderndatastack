FROM python:3.10-slim

ENV DAGSTER_HOME=/opt/dagster/dagster_home
ENV VIRTUAL_ENV=/opt/venv
ENV PATH="/opt/venv/bin:$PATH"

RUN mkdir -p $DAGSTER_HOME

WORKDIR $DAGSTER_HOME

# Install dependencies
RUN apt-get update && apt-get install -y build-essential curl
RUN python -m pip install uv

# Set virtual environment and install requirements
COPY platform/dagster/requirements.txt ${DAGSTER_HOME}/requirements.txt
RUN uv pip install --system --no-cache -r ${DAGSTER_HOME}/requirements.txt

COPY platform/dagster/dagster.yaml platform/dagster/workspace.yaml $DAGSTER_HOME/
WORKDIR $DAGSTER_HOME 