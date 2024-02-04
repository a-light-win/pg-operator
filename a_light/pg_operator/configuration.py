#!/usr/bin/env python3

import json
import pathlib
import logging
from dataclasses import dataclass
import kopf


@dataclass
class InstanceCreationSetting:
    enabled: bool = False


@dataclass
class DatabaseCreationSetting:
    enabled: bool = True


@dataclass
class DatabaseMigrationSetting:
    enabled: bool = True


@dataclass
class PgOperatorConfig:
    instance: InstanceCreationSetting
    database: DatabaseCreationSetting
    migration: DatabaseMigrationSetting

    @classmethod
    def config_path(cls) -> pathlib.Path:
        return pathlib.Path("/etc/pg-operator/config.json")

    def log_feature_gates(self, logger: logging.Logger):
        logger.info("Feature gates:")
        logger.info(
            f'  Instance creation is {"enabled" if self.instance.enabled else "disabled"}'
        )
        logger.info(
            f'  Database creation is {"enabled" if self.database.enabled else "disabled"}'
        )
        logger.info(
            f'  Database migration is {"enabled" if self.migration.enabled else "disabled"}'
        )


@kopf.on.startup()  # type: ignore
def configuration(logger: logging.Logger, memo: kopf.Memo, **_):
    config = PgOperatorConfig.config_path()
    if not config.exists():
        return

    with config.open() as f:
        data = json.load(f)
        instance = InstanceCreationSetting(**data.get("instance", {}))
        database = DatabaseCreationSetting(**data.get("database", {}))
        migration = DatabaseMigrationSetting(**data.get("migration", {}))

        memo.config = PgOperatorConfig(instance, database, migration)

        memo.config.log_feature_gates(logger)
