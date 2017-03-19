#!/usr/bin/python3

from deployconfig import DeployConfig

def apply_local_ip():
    try:
        config = DeployConfig()
        config.init_logger()
        config.find_replace_token_in_file(filePath="../../configs/server/wildfly/standalone-full.xml", \
                                  token='{internal-ip}', \
                                  replaceToken=config.get_local_ip())
    except Exception as err:
        raise

apply_local_ip()