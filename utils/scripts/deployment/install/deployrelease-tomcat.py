#!/usr/bin/python3

from deployrelease import DeployRelease

print("> Initialising deploymment release ...")
deploy_r = DeployRelease()
print("> Deployment release has been initialised, now deploying to tomcat...")
deploy_r.deploy_to_tomcat()
print("> Deployment to tomcat has been successfully completed")
