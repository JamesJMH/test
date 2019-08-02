curBranch=$(git branch | grep \* | cut -d ' ' -f2)
if (echo $curBranch | grep '/'); then
  curBranchList=(${curBranch//// })
  curBranch=${curBranchList[0]}
fi
branch="${curBranch}/reviewdog"
postfix=1
exist=$(git branch | grep -cim1 $curBranch/reviewdog)
while [[ $exist != "0" ]]; do
  echo $postfix
  postfix=$((postfix + 1))
  postfix+=""
  exist=$(git branch | grep -cim1 $curBranch/reviewdog${postfix})
done
branch="$curBranch/reviewdog${postfix}"
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
url=${url:8}
PRNum=${urlList[-1]}
repoName=${urlList[-3]}
echo $url
export CI_PULL_REQUEST=${PRNum}
echo $CI_PULL_REQUEST
export CI_REPO_OWNER=${owner}
echo $CI_REPO_OWNER
export CI_REPO_NAME=${repoName}
echo $CI_REPO_NAME
export CI_COMMIT=$(git rev-parse HEAD)
echo $CI_COMMIT
export CI_BRANCH=$branch
echo $CI_BRANCH
export REVIEWDOG_GITHUB_API_TOKEN=64b7ad5caa85118541d59961498c9d11dcdc43bf
echo $REVIEWDOG_GITHUB_API_TOKEN
golint ./... | reviewdog -f=golint -diff="git diff master" -reporter=github-pr-review
