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
class PgOperatorMemo:
    instance: InstanceCreationSetting
    database: DatabaseCreationSetting
    migration: DatabaseMigrationSetting

    @classmethod
    def config_path(cls) -> pathlib.Path:
        return pathlib.Path("/etc/pg-operator/config.json")


@kopf.on.startup()
def configure(memo: PgOperatorMemo, **_):
    config = PgOperatorMemo.config_path()
    if not config.exists():
        return

    with config.open() as f:
        data = json.load(f)
        memo.instance = InstanceCreationSetting(**data.get("instance", {}))
        memo.database = DatabaseCreationSetting(**data.get("database", {}))
        memo.migration = DatabaseMigrationSetting(**data.get("migration", {}))

        logging.info(
            f'Instance creation is {"enabled" if memo.instance.enabled else "disabled"}'
        )
        logging.info(
            f'Database creation is {"enabled" if memo.database.enabled else "disabled"}'
        )
        logging.info(
            f'Database migration is {"enabled" if memo.migration.enabled else "disabled"}'
        )
