## ssm-management-example - repo to contain the configuration data for services, and gets pushed to AWS SSM

This repo is managed via a build pipeline, any commits that make it to master will be automatically built and pushed to AWS System Manager Parameter store.

It uses ansible playbooks for the configuration, and vaults for secrets.

## Repo setup
After the `git clone`, please add a pre-commit hook with the contents of `script/pre-commit-hook.sh`

```
ln -h ./scripts/pre-commit-hook.sh .git/hooks/pre-commit
```

### Pushing to parameter store manually
WARNING: only push to testing namespaces when testing, all other pushes will happen via a CI process

`ANSIBLE_LIBRARY="../../../library/" ansible-playbook -vvvv $PLAYBOOK_NAME.yml --ask-vault-pass`

The vault password used in this example: `zHp4gxJZYuC3D@^zT^aG8`
