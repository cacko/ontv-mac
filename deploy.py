import gitlab
from gitlab.v4.objects.packages import ProjectPackage
from gitlab.v4.objects.projects import ProjectManager
import json
import semver
from os import environ
from pathlib import Path
import logging



Logger = logging.Logger("ONTV")

deployJson = Path(__file__).parent / "deploy.json"

def getUploadJson():
        data = json.loads(deployJson.read_text())
        version = semver.VersionInfo.parse(data.get("package_version").lstrip("v"))
        data["package_version"] = f"v{version.bump_patch()}"
        deployJson.write_text(json.dumps(data))
        return data

gl = gitlab.Gitlab(url="https://gitlab.com", private_token=environ.get("GITLAB_TOKEN"))

gl.auth()

project_name_with_namespace = "cacko/ontv-mac"
project = gl.projects.get(project_name_with_namespace)

def packages() -> list[ProjectPackage]:
        yield from project.packages.list()

for package in packages():
        package.delete()
        Logger.info(f"deleted package: {package.id}")

package = project.generic_packages.upload(**getUploadJson())

print(package)
