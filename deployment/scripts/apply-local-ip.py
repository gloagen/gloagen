#!/usr/bin/python3

from deployconfig import DeployConfig
from sharedutil import sharedutil

def apply_local_ip_and_move_file():
    try:
        config_file = "../configs/server/wildfly/standalone-full.xml"
        target_config_file = "/opt/server/jboss/wildfy/10.1.0/standalone/configuration/standalone-full.xml"

        sharedutil.shutdown_jboss()

        config = DeployConfig()
        config.set_logger(sharedutil.init_logger("../logs/deploy-configs.log", "deploy-config"))
        config.find_replace_token_in_file(filePath=config_file, \
                                          token='{internal-ip}', replaceToken=config.get_local_ip())

        sharedutil.change_owner_and_move_file(group="glogn-app", owner="wildfy", sourcePath=config_file,
                                              targetPath=target_config_file)
        sharedutil.start_jboss()

    except Exception as err:
        raise


apply_local_ip_and_move_file()
