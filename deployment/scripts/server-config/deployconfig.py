import grp
import logging
import os
import pwd
import requests
import yaml
import fileinput

class DeployConfig:

    def init_logger(self):
        log_file = "../../logs/deployconfig.log"
        lHandler = logging.FileHandler(log_file, mode='a', encoding=None, delay=False)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        lHandler.setFormatter(formatter)
        logger = logging.getLogger('deploy-config')
        logger.setLevel(logging.DEBUG)
        logger.addHandler(lHandler)
        self.logger = logger

    def get_local_ip(self):
        r = requests.get('http://instance-data/latest/meta-data/local-ipv4')
        self.local_ip = r.text
        self.logger.info("retrieved local server ip: "+self.local_ip)
        return self.local_ip

    def find_replace_token_in_file(self, filePath, token, replaceToken):
        self.logger.info("attempting to relace token: "+token+ " with: "+replaceToken+ " in file: "+filePath)
        with fileinput.FileInput(filePath, inplace=True, backup='.bak') as file:
            for line in file:
                self.logger.debug("read line: "+line)
                print (line.replace(token, replaceToken))


