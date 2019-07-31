import subprocess
from subprocess import check_output
import sys

curBranch = subprocess.check_output('git branch | grep \* | cut -d ' ' -f2', shell=True)
if "/" in curBranch:
    curBranch = curBranch.split("/")[0]
postfix = 1
exist = subprocess.check_output('git branch | grep ' + curBranch + '/reviewdog', shell=True)
while exist:
    postfix += 1
    exist = subprocess.check_output('git branch | grep' + curBranch + '/reviewdog' + str(postfix), shell=True)
branch = curBranch + '/reviewdog' + str(postfix)
subprocess.check_output('git co -b ' + branch, shell=True)
print('Number of commits in PR?')
sys.stdout.flush()
numCommits = raw_input()
subprocess.check_output('git reset --soft HEAD~' + numCommits, shell=True)
subprocess.check_output('git commit -m "squashed for review dog"', shell=True)
subprocess.check_output('git push --set-upstream origin ' + branch, shell=True)
print('Merge to which branch?')
sys.stdout.flush()
toBranch = raw_input()
subprocess.check_output('hub pull-request -m "review dog comments" -b ' + toBranch + ' -h ' + branch, shell=True)
