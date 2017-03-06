#!/usr/bin/python3
from scripts.install.deployrelease import DeployRelease

d_rel = DeployRelease()
d_rel.init_logger()
d_rel.deploy_to_tomcat()
