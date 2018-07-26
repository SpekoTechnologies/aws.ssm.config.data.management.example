statuses=$(git status -s | awk '{print $2}' | grep .yml | grep -v vault)
parent_dir=$(pwd)

while [ $# -gt 0 ]; do
   if [[ $1 == *"--"* ]]; then
        v="${1/--/}"
        declare $v="$2"
   fi

  shift
done

if [[ -z "$vault_pass_file" && -z $vault_pass ]]; then
  echo 'vault_pass or vault_pass_file must be specified.'
  exit 1
elif [[ -z $vault_pass_file && $vault_pass ]]; then
  echo $vault_pass > /tmp/temp_ansible_vault_pass.txt
  vault_pass_file=/tmp/temp_ansible_vault_pass.txt
  tmp_vault_file=true
fi

# Variables
if [ -z "$interactive" ]; then
		interactive="true"
		echo "Using default: --interactive true"
fi

if [ -z "$aws_profile" ]; then
		echo "Using default: promt user for --aws_profile"
else
  ignore_aws_profile_prompt=true
fi

# Logic
if [[ $interactive == "false" && ! $aws_profile ]]; then
  echo -e "\n"
  echo "- xxxxxxxxxxxxxxxxx -"
	echo "Oh Snap! :~ aws_profile must be set when --interactive is true"
  echo "- xxxxxxxxxxxxxxxxx -"
  if [ $tmp_vault_file ]; then
    rm $vault_pass_file
  fi
	exit 1
fi

echo -e "\n"

for line in $statuses; do
	if [[ $line == *".yml"* ]]; then
		echo "Found this playbook to push: ${line}.."

		if [[ $interactive == true || $interactive == "true" ]]; then
			read -p "Do you want to proceed? [yY/nN]: " -n 1 -a INTERACTIVE_PROCEED -r
			echo -e "\n"
			if [[ $INTERACTIVE_PROCEED && ! $INTERACTIVE_PROCEED =~ ^[Yy]$ ]]; then
				echo "Skipping: ${line}"
				echo -e "\n"
				echo -e "\n"
				continue
			elif [[ -z $ignore_aws_profile_prompt ]]; then
				read -p "Which profile do you want to use? : " -a PROFILE_PROMPT -r
				aws_profile=$PROFILE_PROMPT
				echo -e "\n"
			fi
		fi

		dir=$(dirname "${line}")
		cd $dir
		file=$(ls | grep .yml | grep -v "vault")
		echo "Pushing ${dir} to ${aws_profile}"

		AWS_PROFILE=$aws_profile ANSIBLE_LIBRARY="${parent_dir}/library/" ansible-playbook -vvvv $file --vault-password-file $vault_pass_file
		cd $parent_dir

		echo -e "\n"
		echo -e "\n"
	fi
done

if [ $tmp_vault_file ]; then
  rm $vault_pass_file
fi
