{% from "gitrepos/map.jinja" import gitrepos with context %}

test-1:
  cmd.run:
    - name: echo "TESTING is here {{ gitrepos.env }} {{ gitrepos.app_user }} {{ gitrepos.project.name }}"
