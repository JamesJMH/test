curBranch=$(git branch | grep \* | cut -d ' ' -f2)
if !(echo "$string" | grep 'foo'); then
  curBranchList=(${curBranch//// })
  curBranch=${curBranchList[0]}
fi
echo $curBranch
git co -b $curBranch/reviewdog
git add .
git reset --soft HEAD~3
git commit -m 'squash dog'
