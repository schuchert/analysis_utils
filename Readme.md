These instructions assume you have a bash-like shell. Any unix will be fine. Mac OS as well. For windows, consider using [git bash](https://gitforwindows.org/).

## Tools needed:
* Git
* PMD (downloaded automatically)
* bash 
* curl

## Using
* Clone this repo (assuming the directory ~/src/analysis_utils for remainder of instructions)
```
cd ~/src
git clone git@github.com:schuchert/analysis_utils.git
```
* Switch to a git repository
```
cd ~/src/some_git_repo
```

### Check for duplication in most recent commit
```
~/src/analysis_utils/dups_in_this_commit.sh 2>/dev/null > dups.txt
```
### Look for cyclomatic complexity issues by each commit
```
~/src/analysis_utils/pmd_walk.sh cc.xml 2>/dev/null > cc_report.txt
```
### Look for code duplication by each commit
```
~/src/analysis_utils/historical_duplication.sh 2>/dev/null > dup_report.txt
```

### Check for dups across several children directories under current directory
```
cd ~/src # note is a top-level directory where I clone my repos
~/src/analysis_utils/dups_across_all.sh
```

This will find all directories under the current one with a src directory.
Then for each directory, cd into in, run dups_in_this_commit.sh.

