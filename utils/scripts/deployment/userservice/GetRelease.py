import yaml
import requests
import os
from pathlib import Path


class GetUserServiceRelease:
    """ Utility class to read the user service relased archive
        and update tomcat with the downloaded release """

    def ___init___(self):
        self.data = []

    def create_file_path(self, filename):
        return "../properties/" + filename

    def get_release_properties(self):
        releaseProps = self.read_data("release.yml")
        return releaseProps

    def get_app_properties(self):
        appProperties = self.read_data("app-properties.yml")
        return appProperties

    def build_archive_path(self, properties):
        filename = properties['tomcat']['target-name'] + "." + properties['release']['type']
        return self.create_file_path(filename)

    def read_data(self, filename):
        with open(self.create_file_path(filename), "r") as filedata:
            return yaml.load(filedata)

    def generate_artifact_download_url(self):
        releaseProps = self.get_release_properties()
        url = self.get_app_properties()['artifactory']['repository']['release']['url']
        url = url.replace("{groupid-directory}", releaseProps['release']['groupid-directory'])
        url = url.replace("{app-name}", releaseProps['release']['name'])
        url = url.replace("{version}", releaseProps['release']['version'])
        url = url.replace("{type}", releaseProps['release']['type'])
        return url

    def build_release_filename(self):
        releaseProps = self.get_release_properties()
        return releaseProps['tomcat']['target-name'] + "." + releaseProps['release']['type']

    def create_artifact_download_fullpath(self):
        appProperties = self.get_app_properties()
        filename = os.path.join(appProperties['archive']['download']['directory'], self.build_release_filename())
        print("generated artifact full path is : ", filename)
        return filename

    def get_artifact_repository_login_user(self):
        return self.get_app_properties()['artifactory']['user']

    def get_artifact_repository_login_password(self):
        return self.get_app_properties()['artifactory']['password']

    def get_artifact_download_chunk_size(self):
        return self.get_app_properties()['archive']['download']['chunk_size']

    def download_released_artifact(self):
        req = requests.get(self.generate_artifact_download_url(),
                           auth=(
                               self.get_artifact_repository_login_user(),
                               self.get_artifact_repository_login_password()),
                           stream=True)

        print("created request with url:", req.url)

        artifactPath = self.create_artifact_download_fullpath()
        with open(artifactPath, "wb") as relFile:
            print("downloading artifact ....")
            for chunk in req.iter_content(chunk_size=self.get_artifact_download_chunk_size()):
                relFile.write(chunk)

        print("Download has now completed")
        return artifactPath

    def get_tomcat_webapps_directory(self):
        return self.get_app_properties()['tomcat']['webapps']['directory']

    def remove_previous_deployment(self):
        filename = os.path.join(self.get_tomcat_webapps_directory(), self.build_release_filename())
        print("file name: ", filename)
        print("Checking if file exist in tomcat webapps directory")
        if os.path.exists(filename):
            print("found file, now deleting ...")
            os.remove(filename)
            print("file have now been deleted.")
        else:
            print("file not founf in tomcat directory!")
        return filename

    def deploy_to_tomcat(self):
        artifact = self.download_released_artifact()
        print("downloaded articfact:", artifact)
        targetArtifact = self.remove_previous_deployment()
        os.rename(artifact, targetArtifact)
        print("deplpoyment completed.")
