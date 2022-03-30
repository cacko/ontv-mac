from ctypes import _CArgObject
from github import (
    Github,
    GitRelease
)
from os import environ
from faker import Faker
from subprocess import check_output

fake = Faker()
release_description = fake.paragraph()
print(release_description)

version = check_output(["agvtool", "vers", "-terse"]).decode().strip()


repo = Github(environ.get("GITHUB_TOKEN")).get_repo("cacko/ontv-mac")


release: GitRelease = repo.create_git_tag_and_release(f"v0.1.{version}", release_message=release_description)

release.GitRelease.upload_asset('ontv.dmg')
 