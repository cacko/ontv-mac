from github import (
    Github
)
from os import environ
from faker import Faker
from subprocess import check_output

fake = Faker()
release_description = fake.paragraph()
print(release_description)

version = check_output(["agvtool", "vers", "-terse"]).decode().strip()

repo = Github(environ.get("GITHUB_TOKEN")).get_repo("cacko/ontv-mac")

release_version = f"v2.1.{version}"

commit = repo.get_branch("master").commit

release = repo.create_git_tag_and_release(
    release_version, release_description, release_version, release_description, commit.sha, ''
    )

release.upload_asset('ontv-arm64.dmg')
 