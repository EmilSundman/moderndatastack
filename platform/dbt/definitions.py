from pathlib import Path
import os
from dagster_dbt.asset_decorator import dbt_assets
from dagster_dbt import dbt_assets,  DbtCliResource, DagsterDbtTranslator, DagsterDbtTranslatorSettings
from dagster import (
    Definitions,    
    AssetExecutionContext
)

MANIFEST_PATH = "/opt/dagster/app/location_dbt_layer/target/manifest.json"
DBT_PROJECT_DIR = "/opt/dagster/app/location_dbt_layer/"
DBT_PROFILES_DIR = "/opt/dagster/app/location_dbt_layer/"
dbt_cli_args = ['--project-dir', f'{DBT_PROJECT_DIR}', '--profiles-dir', f'{DBT_PROFILES_DIR}']

dbt_translator = DagsterDbtTranslator(
    settings=DagsterDbtTranslatorSettings(
        enable_asset_checks=True # Change to True to enable asset checks
        )
    )

@dbt_assets(manifest=Path(MANIFEST_PATH), 
            select="fqn:*", 
            exclude="tag:daily_partition",
            dagster_dbt_translator=dbt_translator
            )
def non_partitioned_dbt_assets(
    context: AssetExecutionContext, 
    dbt: DbtCliResource
):
    
    dbt_task = dbt.cli(
        ["build", *dbt_cli_args], 
        context=context
        )
    
    yield from dbt_task.stream()

resources = {
    "LOCAL":{
        # this resource is used to execute dbt cli commands
        "dbt": DbtCliResource(
            project_dir=DBT_PROJECT_DIR,
            profiles_dir = DBT_PROFILES_DIR,
            profile="dbt_core",
            target='duckdb_dev'
        )
    },
    "DEV":{
        "dbt": DbtCliResource(
            project_dir=DBT_PROJECT_DIR,
            profiles_dir = DBT_PROFILES_DIR,
            profile="dbt_core",
            target='duckdb_dev'
        )
    },
    "PROD":{
        "dbt": DbtCliResource(
            project_dir=DBT_PROJECT_DIR,
            profiles_dir = DBT_PROFILES_DIR,
            profile="dbt_core",
            target='duckdb_prod'
        )
    }
}

defs = Definitions(
    assets=[
            non_partitioned_dbt_assets
            ],
    resources=resources.get(os.getenv("ENVIRONMENT", "LOCAL")),
)