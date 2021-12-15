from dataclasses import dataclass
from dataclasses_json import dataclass_json, Undefined
from semver import VersionInfo


@dataclass_json(undefined=Undefined.EXCLUDE)
@dataclass
class DeployJSON:
    package_name: str
    package_version: str
    file_name: str
    path: str

    def bump_version(self):
        version = VersionInfo.parse(self.package_version.lstrip("v"))
        self.package_version = f"v{version.bump_patch()}"

@dataclass_json(undefined=Undefined.EXCLUDE)
@dataclass
class Release:
    tag_name: str
    description: str
