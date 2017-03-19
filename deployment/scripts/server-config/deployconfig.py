import grp
import logging
import os
import pwd
import requests
import yaml
import fileinput

class DeployConfig:

    def get_local_ip(self):
        r = requests.get('http://instance-data/latest/meta-data/local-ipv4')
        self.local_ip = r.text
        return self.local_ip

    def find_replace_token_in_file(self, filePath, token, replaceToken):
        with fileinput.FileInput(filePath, inplace=True, backup='.bak') as file:
            for line in file:
                print (line.replace(token, replaceToken))


