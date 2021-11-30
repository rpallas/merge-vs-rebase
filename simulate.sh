#!/bin/bash

repos="merge rebase"
rm -rf $repos
mkdir $repos

function create_branch() {
  local ticketName=$1
  git checkout -b $ticketName
}

function work_on() {
  local ticketName=$1
  local start=$2
  local changes=$3
  git checkout $ticketName
  for ((i=$start;i<$start+$changes;i++)); do
    echo "$ticketName - change $i" >> $ticketName
    git add -A
    git commit -qm "change $i"
  done
  git checkout master
}

function initial_commit() {
  echo "initial commit" >> README.md
  git add -A
  git commit -qm "initial commit"
}

function git_log() {
  local repo=$1
  pushd $repo
  git --no-pager log --all --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset'
  popd
}

function sync() {
  local branch=$1
  local syncType=$2
  git checkout $branch
  if [ "$syncType" == "merge" ]
    then
      git merge --ff --no-edit master
  elif [ "$syncType" == "rebase" ]
    then
      git rebase master
  fi
  git checkout master
}

function merge_to_master() {
  local branch=$1
  git checkout master
  git merge --no-edit --no-ff $branch
  git branch -d $branch
}

function simulate_work() {
  local syncType=$1
  create_branch TICKET-1
  work_on TICKET-1 1 2
  create_branch TICKET-2
  work_on TICKET-2 1 2
  work_on TICKET-1 3 2
  merge_to_master TICKET-1
  sync TICKET-2 $syncType
  work_on TICKET-2 3 4
  create_branch TICKET-3
  work_on TICKET-3 1 2
  # work_on TICKET-2 8 100
  merge_to_master TICKET-2
  sync TICKET-3 $syncType
  work_on TICKET-3 3 4
  merge_to_master TICKET-3
}

for repo in $repos; do
  pushd $repo
  git init -q

  initial_commit
  simulate_work $repo

  popd
done

git_log merge
git_log rebase