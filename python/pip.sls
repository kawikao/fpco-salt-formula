# ensure pip is installed, through apt, and salt's modules are reloaded
{%- set default_pip_version = "pip<10.0" %}
{%- set pip_version = salt['pillar.get']('pip_version', default_pip_version) %}

include:
  - python


# install pip with easy_install, if it is missing
pip:
  cmd.run:
    - name: easy_install -U pip "{{ pip_version }}"
    - unless: which pip
    - require:
        - pkg: python-setuptools

# ensure pip is upgraded
pip-upgrade:
  cmd.run:
    - name: pip install --upgrade "{{ pip_version }}"
    - require:
        - cmd: pip

# which version?
pip-echo-version:
  cmd.run:
    - name: pip --version
    - watch:
        - cmd: pip
        - cmd: pip-upgrade

# if we update the pip package, we need to reload modules
pip-refresh_modules:
  module.wait:
    - name: saltutil.refresh_modules
    - watch:
        - cmd: pip
        - cmd: pip-upgrade
