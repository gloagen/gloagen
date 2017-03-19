#!/usr/bin/python3
from deployrelease import DeployRelease


def deploy_tomcat():
    d_rel = DeployRelease()
    d_rel.deploy_to_tomcat()


deploy_tomcat()
