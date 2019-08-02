curBranch=$(git branch | grep \* | cut -d ' ' -f2)
if (echo $curBranch | grep '/'); then
  curBranchList=(${curBranch//// })
  curBranch=${curBranchList[0]}
fi
branch="${curBranch}/reviewdog"
postfix=1
exist=$(git branch | grep -cim1 $curBranch/reviewdog)
while [[ $exist -eq 1 ]]; do
  postfix=$postfix+1
  exist=$(git branch | grep -cim1 $curBranch/reviewdog/${postfix})
done
branch = "${curBranch}/reviewdog"
git co -b $branch
git add .
echo "How many commits to squash?"
read num
git reset --soft HEAD~${num}
git commit -m 'squash dog'
git push --set-upstream origin $branch
echo 'Merge to which branch? Enter in format [owner]:[branch]'
read toBranch
toBranchList=(${toBranch//:/ })
owner=${toBranchList[0]}
url=$(hub pull-request -m "review dog comments" -b $toBranch -h $branch)
urlList=(${url//// })
PRNum=urlList[-1]
repoName=urlList[-3]
export CI_PULL_REQUEST=${PRNum}
export CI_REPO_OWNER=${owner}
export CI_REPO_NAME=${repoName}
export CI_COMMIT=$(git rev-parse HEAD)
export CI_BRANCH=$branch
export REVIEWDOG_GITHUB_API_TOKEN=64b7ad5caa85118541d59961498c9d11dcdc43bf
golint ./... | reviewdog -f=golint -diff="git diff master" -reporter=github-pr-review
