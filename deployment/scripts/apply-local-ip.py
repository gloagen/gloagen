#!/usr/bin/python3

from deployconfig import DeployConfig
from sharedutil import sharedutil

def apply_local_ip_and_move_file():
    try:
        config_file = "../configs/server/wildfly/standalone-full.xml"
        target_config_file = "/opt/server/jboss/wildfy/10.1.0/standalone/configuration/standalone-full.xml"

        logger = sharedutil.init_logger("../logs/deploy-configs.log", "deploy-config")

        logger.info("starting shutdown of current running jboss server...")
        sharedutil.shutdown_jboss()

        logger.info("shutdown has completed.")

        config = DeployConfig()
        config.set_logger(sharedutil.init_logger("../logs/deploy-configs.log", "deploy-config"))
        config.find_replace_token_in_file(filePath=config_file, \
                                          token='{internal-ip}', replaceToken=config.get_local_ip())

        logger.info("successfully modified config file .. now moving to target: " + target_config_file)
        sharedutil.change_owner_and_move_file(group="glogn-app", owner="wildfy", sourcePath=config_file,
                                              targetPath=target_config_file)

        logger.info("now attempting to restart wildfy application server")
        pid = sharedutil.start_jboss()

        logger.info("wildfy application server has been restarted with pid: " + pid)

    except Exception as err:
        raise


apply_local_ip_and_move_file()
