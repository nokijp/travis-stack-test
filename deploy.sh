#!/bin/bash

set -e

git_user='Travis CI'
git_email="$DEPLOY_USER_EMAIL"
git_commit_message='deploy to gh-pages'

tmp_dir=dist
target_branch=gh-pages
encryption_label="$ENCRYPTION_LABEL"

git_repo="$(git config remote.origin.url)"
git_ssh_repo="${git_repo/https:\/\/github.com\//git@github.com:}"

stack_dist_dir="$(stack path --dist-dir)"

rm -rf "$tmp_dir"
git clone "$git_repo" "$tmp_dir"
cd "$tmp_dir"
git checkout "$target_branch" || git checkout --orphan "$target_branch"

cp "../$stack_dist_dir/"*-*.tar.gz .

if [ -z `git diff --exit-code` ]; then
  echo 'nothing to commit'
  exit 0
fi

git config user.name "$git_user"
git config user.email "$git_email"

git add .
git commit -m "$git_commit_message"

encrypted_key_var="encrypted_${encryption_label}_key"
encrypted_iv_var="encrypted_${encryption_label}_iv"
openssl aes-256-cbc -K "${!encrypted_key_var}" -iv "${!encrypted_iv_var}" -in deploy_key.enc -out deploy_key -d
chmod 600 deploy_key
eval "$(ssh-agent -s)"
ssh-add deploy_key

git push "$git_ssh_repo" "$target_branch"
