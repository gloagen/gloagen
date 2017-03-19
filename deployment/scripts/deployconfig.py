import grp
import logging
import os
import pwd
import requests
import yaml
import fileinput

class DeployConfig:
    def set_logger(self, logger):
        self.logger = logger

    def get_local_ip(self):
        r = requests.get('http://instance-data/latest/meta-data/local-ipv4')
        self.local_ip = r.text
        logger.info("retrieved local server ip: " + self.local_ip)
        return self.local_ip

    def find_replace_token_in_file(self, filePath, token, replaceToken):
        self.logger.info("attempting to relace token: " + token + " with: " + replaceToken + " in file: " + filePath)
        with fileinput.FileInput(filePath, inplace=True, backup='.bak') as file:
            for line in file:
                print (line.replace(token, replaceToken), end='')
            logger.info("relaced all matched tokens in file: " + filePath)
            return filePath
