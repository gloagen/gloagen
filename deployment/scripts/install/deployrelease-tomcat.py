#!/usr/bin/python3
from deployrelease import DeployRelease


def deploy_tomcat(self):
    d_rel = DeployRelease()
    d_rel.init_logger()
    d_rel.deploy_to_tomcat()


deploy_tomact()
