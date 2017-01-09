{% set user = 'ec2-user' %}
{% set group = 'ec2-user' %}

gitrepos:
  lookup:
    app_user: {{ user }}
    app_group: {{ group }}
    root_user: root
    project:
      name: default_project_name
    # This is the Django project
    # The env variable determines DJANGO_SETTINGS_MODULE used
    env: local
    # using a public Github repository
    repo: git@github.com:alexisbellido/basic-django-project.git
    branch: master
    # using a private repository
    #repo: user@example.com:/home/user/git/basic-django-project.git
    user:
      name: Joe Doe
      email: user@example.com

    # Editable Django applications to clone
    # editable has to be set to True.
    pip_packages:
      /home/ec2-user/djapps/django-zinibu-skeleton:
        editable: True # local source code, useful for development
        repo: user@example.com:/home/user/git/django-zinibu-skeleton.git
        branch: master
