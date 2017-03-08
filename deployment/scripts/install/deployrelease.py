import logging
import os

import requests
import yaml


def call_clsinit(*args, **kwargs):
    cls = type(*args, **kwargs)
    cls._clsinit()
    return cls;

class DeployRelease:
    """ Utility class to read the user service relased archive
        and update tomcat with the downloaded release """

    __metaclass__ = call_clsinit

    @classmethod
    def _clsinit(cls):
        init_logger()

    def init_logger(self):
        log_file = os.path.join(os.environ.get('GLOAG_DEPLOY_HOME'), "logs", "deployrelease.log")
        # logging.basicConfig(filename=log_file, level=logging.DEBUG, format='%(asctime)s %(message)s')
        lHandler = logging.FileHandler(log_file, mode='a', encoding=None, delay=False)
        # lHandler = logging.RotatingFileHandler(log_file, mode='a', maxBytes=1000000, backupCount=5, encoding=None,
        #                                             delay=0)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        lHandler.setFormatter(formatter)
        logger = logging.getLogger('deploy-release')
        logger.setLevel(logging.DEBUG)
        logger.addHandler(lHandler)
        self.logger = logger

    def ___init___(self):
        self.data = []

    def get_release_properties(self):
        release_file_path = os.path.join(os.environ.get('GLOAG_DEPLOY_RELEASE_PROPERTIES_HOME'), "userservice.yml")
        return self.read_data(release_file_path)

    def get_app_properties(self):
        appProperties_file_path = os.path.join(os.environ.get('GLOAG_DEPLOY_PROPERTIES_HOME'), "app-properties.yml")
        return self.read_data(appProperties_file_path)

    def read_data(self, filename):
        self.logger.info("attempting to read data with file name: " + filename)
        with open(filename, "r") as filedata:
            return yaml.load(filedata)

    def generate_artifact_download_url(self):
        releaseProps = self.get_release_properties()
        url = self.get_app_properties()['artifactory']['repository']['release']['url']
        url = url.replace("{groupid-directory}", releaseProps['release']['groupid-directory'])
        url = url.replace("{app-name}", releaseProps['release']['name'])
        url = url.replace("{version}", releaseProps['release']['version'])
        url = url.replace("{type}", releaseProps['release']['type'])
        self.logger.info("generated artifact url is: " + url)
        return url

    def build_release_filename(self):
        releaseProps = self.get_release_properties()
        return releaseProps['tomcat']['target-name'] + "." + releaseProps['release']['type']

    def create_artifact_download_fullpath(self):
        appProperties = self.get_app_properties()
        filename = os.path.join(os.environ.get('GLOAG_DEPLOY_DOWNLOADS_HOME'), self.build_release_filename())
        self.logger.info("generated artifact full path is : ", filename)
        return filename

    def get_artifact_repository_login_user(self):
        return self.get_app_properties()['artifactory']['user']

    def get_artifact_repository_login_password(self):
        return self.get_app_properties()['artifactory']['password']

    def get_artifact_download_chunk_size(self):
        return self.get_app_properties()['archive']['download']['chunk_size']

    def download_released_artifact(self):
        download_url = self.generate_artifact_download_url()
        req = requests.get(self.generate_artifact_download_url(),
                           auth=(
                               self.get_artifact_repository_login_user(),
                               self.get_artifact_repository_login_password()),
                           stream=True)

        self.logger.info("created request with url:", req.url)

        artifactPath = self.create_artifact_download_fullpath()
        with open(artifactPath, "wb") as relFile:
            self.logger.info("downloading artifact ....")
            for chunk in req.iter_content(chunk_size=self.get_artifact_download_chunk_size()):
                relFile.write(chunk)

        self.logger.info("Download has now completed")
        return artifactPath

    def get_tomcat_webapps_directory(self):
        return os.environ.get('GLOAG_WEBAPPS_HOME')

    def remove_previous_deployment(self):
        filename = os.path.join(self.get_tomcat_webapps_directory(), self.build_release_filename())
        self.logger.info("file name: ", filename)
        self.logger.info("Checking if file exist in tomcat webapps directory")
        if os.path.exists(filename):
            self.logger.info("found file, now deleting ...")
            os.remove(filename)
            self.logger.info("file have now been deleted.")
        else:
            self.logger.info("file not founf in tomcat directory!")
        return filename

    def deploy_to_tomcat(self):
        try:
            self.load_properties()
            self.logger.info("commencing deplyment to tomcat..")
            artifact = self.download_released_artifact()
            self.logger.info("downloaded articfact:", artifact)
            targetArtifact = self.remove_previous_deployment()
            os.rename(artifact, targetArtifact)
            self.logger.info("deployment completed.")
        except Exception as err:
            self.logger.error("Caught an exception whilst attempting to deploy to tomcat: {0}".format(err), err)
            raise

    def load_properties(self):
        path = "../properties/app-properties.yml"
        self.appProperties = self.read_data(path)
