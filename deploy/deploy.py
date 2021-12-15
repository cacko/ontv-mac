from typing import Generator
import gitlab
from gitlab.v4.objects.packages import ProjectPackage, GenericPackage
from gitlab.v4.objects.projects import (
    Project,
    ProjectReleaseManager,
    GenericPackageManager,
)
from os import environ
from pathlib import Path
import logging
from models import DeployJSON
from subprocess import call
from shlex import join
import requests
import argparse
from faker import Faker

fake = Faker()

Logger = logging.Logger("ONTV")
GIT = "/usr/local/bin/git"

#       - git commit -am "fix CVE-2021-44228"


def message():
    return requests.get("https://commit.cacko.net/index.txt").text.strip()


def run(*cmd):
    return call(join(cmd), shell=True)


def git(*args):
    run(GIT, *args)


def gitpush(comment, version):
    git("commit", "-am", comment)
    git("push")
    git("tag", "-a", version, "-m", comment)
    git("push", "origin", version)


def getUploadJson() -> DeployJSON:
    path = Path(__file__).parent / "deploy.json"
    deployJson: DeployJSON = DeployJSON.from_json(path.read_text())
    deployJson.bump_version()
    path.write_text(deployJson.to_json())
    return deployJson


def packages(project: Project) -> Generator[ProjectPackage, None, None]:
    yield from project.packages.list()


def package_for_version(project: Project, version: str) -> ProjectPackage:
    for package in packages(project):
        if package.version == version:
            return package


def delete_packages(project: Project):
    for package in packages(project):
        package.delete()
        Logger.info(f"deleted package: {package.id}")


if __name__ == "__main__":
    PARSER = argparse.ArgumentParser()
    PARSER.add_argument("name", nargs="?", default="", help="pi4")
    args = PARSER.parse_args()
    gl = gitlab.Gitlab(
        url="https://gitlab.com", private_token=environ.get("GITLAB_TOKEN")
    )
    gl.auth()
    project_name_with_namespace = "cacko/ontv-mac"
    project = gl.projects.get(project_name_with_namespace)
    deployJSON = getUploadJson()
    package: GenericPackage = project.generic_packages.upload(**deployJSON.to_dict())
    version_name = args.name if args.name != "" else message()
    gitpush(version_name, deployJSON.package_version)
    new_package = package_for_version(project, deployJSON.package_version)
    new_file = new_package.package_files.list()[0]
    downloadUrl = f"https://gitlab.com/{project_name_with_namespace}/-/package_files/{new_file.id}/download"
    releases: ProjectReleaseManager = project.releases
    fake = Faker()
    for release in releases.list():
            release.delete()
    release = releases.create(
        {
            "tag_name": deployJSON.package_version,
            "name": version_name,
            "description": fake.paragraph(),
            "assets": {
                "links": [
                    {
                        "name": deployJSON.file_name,
                        "url": downloadUrl,
                    }
                ]
            },
        }
    )
    print(release)
