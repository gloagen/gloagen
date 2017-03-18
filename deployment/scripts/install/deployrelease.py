import grp
import logging
import os
import pwd
import requests
import yaml


class DeployRelease:
    """ Utility class to read the user service relased archive
        and update tomcat with the downloaded release """

    def init_logger(self):
        log_file = "../../logs/deployrelease.log"
        lHandler = logging.FileHandler(log_file, mode='a', encoding=None, delay=False)
        formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
        lHandler.setFormatter(formatter)
        logger = logging.getLogger('deploy-release')
        logger.setLevel(logging.DEBUG)
        logger.addHandler(lHandler)
        self.logger = logger

    def ___init___(self):
        self.data = []

    def read_data(self, filename):
        self.logger.info("attempting to read data with file name: " + filename)
        with open(filename, "r") as filedata:
            return yaml.load(filedata)

    def generate_artifact_download_url(self):
        url = self.appProperties['artifactory']['repository']['release']['url'] \
            .replace("{groupid-directory}", self.releaseProperties['release']['groupid-directory']) \
            .replace("{app-name}", self.releaseProperties['release']['name']) \
            .replace("{version}", self.releaseProperties['release']['version']) \
            .replace("{type}", self.releaseProperties['release']['type'])
        self.logger.info("generated artifact url is: " + url)
        return url

    def build_release_filename(self):
        return self.releaseProperties['tomcat']['target-name'] + "." + self.releaseProperties['release']['type']

    def create_artifact_download_fullpath(self):
        filename = os.path.join("../../downloads", self.build_release_filename())
        self.logger.info("generated artifact full path is : ", filename)
        return filename

    def get_artifact_repository_login_user(self):
        return self.appProperties['artifactory']['user']

    def get_artifact_repository_login_password(self):
        return self.appProperties['artifactory']['password']

    def get_artifact_download_chunk_size(self):
        return self.appProperties['archive']['download']['chunk_size']

    def download_released_artifact(self):
        download_url = self.generate_artifact_download_url()
        req = requests.get(download_url,
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

        self.logger.info("Download has now completed for artifact: " + artifactPath)
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
            self.logger.info("file not found in tomcat directory!")
        return filename

    def deploy_to_tomcat(self):
        try:

            self.load_properties()
            self.logger.info("commencing deplyment to tomcat..")
            artifact = self.download_released_artifact()

            uid = pwd.getpwnam("gloag").pw_uid
            gid = grp.getgrnam("gloag").gr_gid
            os.chown(artifact, uid, gid)
            self.logger.info("change artifact ownership to gloag")

            targetArtifact = self.remove_previous_deployment()
            os.rename(artifact, targetArtifact)
            self.logger.info("deployment completed.")

        except Exception as err:
            self.logger.error("Caught an exception whilst attempting to deploy to tomcat: {0}".format(err), err)
            raise

    def load_properties(self):
        path = os.path.dirname(os.path.realpath(__file__))
        os.chdir(path)
        self.init_logger()
        path = "../../properties/app-properties.yml"
        self.appProperties = self.read_data(path)
        self.logger.info("loaded application properties")
        self.releaseProperties = self.read_data("../../properties/release.yml")
        self.logger.info("loaded release properties")
