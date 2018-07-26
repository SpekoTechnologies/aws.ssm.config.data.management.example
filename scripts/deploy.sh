#! /usr/bin/env bash
export ALLOW_PARAM_OVERWRITE=false
files=`git log -m -n 1 --name-only --pretty=format:"" | egrep -Eio '\w*\/\w*\/\w*\/\w*.yml'`
changed_dirs=`echo "$files" | egrep -Eio '\w*\/\w*\/\w*' | uniq`
echo "Changed files are"
echo "$files"
for dir in $changed_dirs; do
  echo "======================"
  echo "Changes detected in $dir"
  cd $dir
  playbook=$(ls | grep -v vault | head -n 1)
  echo "Running playbook $playbook"
  ansible-playbook -i localhost, --vault-password-file $VAULT_PASS_FILE $playbook |& tee -a /tmp/push.log
  echo "Playbook run complete"
  cd -
done
