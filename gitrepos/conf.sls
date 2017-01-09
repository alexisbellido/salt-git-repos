{% from "gitrepos/map.jinja" import gitrepos with context %}

{% set project_dir = '/home/' + gitrepos.app_user + '/' + gitrepos.project.name %}

# This is used with salt-run state.orchestrate zinibu.deploy
# which is used only after the initial install has been done.
# see zinibu.deploy in https://github.com/alexisbellido/salt-django-stack
{% set deploy = salt['pillar.get']('deploy', False) %}
{% set apps = salt['pillar.get']('apps', []) %}
{% set deploy_target = salt['pillar.get']('deploy_target', '') %}

{% set project_branch = salt['pillar.get']('project_branch', '') %}

{% if deploy %}

deploying:
  cmd.run:
    - name: echo "Deploy project {{ gitrepos.repo }}\nBranch {{ gitrepos.branch }} ..."

{% else %}

{{ project_dir }}:
  file.directory:
    - user: {{ gitrepos.app_user }}
    - group: {{ gitrepos.app_group }}
    - mode: 755
    - makedirs: True

{% endif %}

clone-git-repo:
  git.latest:
    - name: {{ gitreposrepo }}
    - rev: {{ gitreposbranch }}
    - branch: {{ gitreposbranch }}
    - user: {{ gitrepos.app_user }}
    - target: {{ project_dir }}
    - identity: /home/{{ gitrepos.app_user }}/.ssh/id_rsa
    - force_checkout: True
    - force_clone: True
    - force_reset: True
{% if not deploy %}
    - require:
      - file: {{ project_dir }}
      - git: setup-git-user-name
      - git: setup-git-user-email
{% endif %}

{%- if 'pip_packages' in gitrepos%}
  {%- for pip_package, properties in gitrepospip_packages.iteritems() %}

    {%- if deploy %}
      {%- if (apps|length and pip_package in apps) or not apps %}
deploying-package-{{ pip_package }} :
  cmd.run:
      {%- if 'branch' in properties %}
        {% set package_branch = properties.branch %}
      {%- else %}
        {% set package_branch = 'master' %}
      {%- endif %}
    - name: echo "Deploy application {{ pip_package }}\nBranch {{ package_branch }} ..."
      {%- endif %} # apps passed or no apps specified
    {%- endif %} # deploy

# We just clone editable Python packages
{%- if 'editable' in properties %}

create_gitreposapp_directory_{{ pip_package }}:
  file.directory:
    - name: {{ pip_package }}
    - user: {{ gitrepos.app_user }}
    - group: {{ gitrepos.app_group }}
    - mode: 755
    - makedirs: True

{%- if (apps|length and pip_package in apps) or not apps %}
clone-gitreposapp-repo-{{ pip_package }}:
  git.latest:
    - name: {{ properties.repo }}
{%- if 'branch' in properties %}
    - rev: {{ properties.branch }}
    - branch: {{ properties.branch }}
{%- endif %} # branch
    - user: {{ gitrepos.app_user }}
    - target: {{ pip_package }}
    - identity: /home/{{ gitrepos.app_user }}/.ssh/id_rsa
    - force_checkout: True
    - force_clone: True
    - force_reset: True
{% if not deploy %}
    - require:
      - file: create_gitreposapp_directory_{{ pip_package }}
      - git: setup-git-user-name
      - git: setup-git-user-email
{%- endif %} # not deploy
{%- endif %} # apps passed or no apps specified

{%- endif %} # editable

  {%- endfor %} # loop over pip_packages

{%- endif %} # pip_packages in gitrepos
