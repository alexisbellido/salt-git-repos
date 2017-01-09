{% from "gitrepos/map.jinja" import gitrepos with context %}

#test-1:
#  cmd.run:
#    - name: echo "TESTING is here {{ gitrepos.env }} {{ gitrepos.app_user }} {{ gitrepos.project.name }} {{ gitrepos.user.name }} {{ gitrepos.user.email }} "

setup-git-user-name:
  git.config_set:
    - name: user.name
    - value: {{ gitrepos.user.name }}
    - user: {{ gitrepos.app_user }}
    - global: True

setup-git-user-email:
  git.config_set:
    - name: user.email
    - value: {{ gitrepos.user.email }}
    - user: {{ gitrepos.app_user }}
    - global: True
