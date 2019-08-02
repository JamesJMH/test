import subprocess
from subprocess import check_output
import sys


curBranch = subprocess.check_output('git branch | grep \* | cut -d \' \' -f2', shell=True)
if "/" in curBranch:
    curBranch = curBranch.split("/")[0]
postfix = 1
branch = curBranch + '/reviewdog'
try:
    exist = subprocess.check_output('git branch | grep ' + curBranch + '/reviewdog', shell=True)
    while True:
        postfix += 1
        exist = subprocess.check_output('git branch | grep ' + curBranch + '/reviewdog' + str(postfix), shell=True)
except:
    1
branch = curBranch + '/reviewdog' + str(postfix)
subprocess.check_output('git co -b ' + branch, shell=True)
print('Number of commits in PR?')
sys.stdout.flush()
numCommits = raw_input()
subprocess.check_output('git reset --soft HEAD~' + numCommits, shell=True)
subprocess.check_output('git commit -m "squashed for review dog"', shell=True)
subprocess.check_output('git push --set-upstream origin ' + branch, shell=True)
print('Merge to which branch? Enter in format [owner]:[branch]')
sys.stdout.flush()
toBranch = raw_input()
owner = toBranch.split(":")[0]
url = subprocess.check_output('hub pull-request -m "review dog comments" -b ' + toBranch + ' -h ' + branch, shell=True)
PRNum = url.split("/")[-1]
repoName = url.split("/")[-3]
subprocess.check_output('export CI_PULL_REQUEST=' + PRNum, shell=True)
subprocess.check_output('export CI_REPO_OWNER=' + owner, shell=True)
subprocess.check_output('export CI_REPO_NAME=' + repoName, shell=True)
subprocess.check_output('export CI_COMMIT=$(git rev-parse HEAD)', shell=True)
subprocess.check_output('export CI_BRANCH=' + branch, shell=True)
subprocess.check_output('export REVIEWDOG_GITHUB_API_TOKEN=13862f8280c3e76607bade5e89ff5078c96d5107',shell=True)
subprocess.check_output('golint ./... | reviewdog -f=golint -diff="git diff master" -reporter=github-pr-review', shell=True)
