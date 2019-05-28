saltgui packages needed:
  pkg.installed:
    - pkgs:
      - salt-api
      - python-cherrypy3

/srv/saltgui:
  file.directory:
    - name: /etc/saltgui

saltgui clone git:
  git.cloned:
    - name: https://github.com/erwindon/SaltGUI.git
    - target: /opt/saltgui/

synchronize webstuff:
  rsync.synchronized:
    - source: /opt/saltgui/saltgui/
    - name: /srv/saltgui/ 
    - prepare: true
    - require:
      - saltgui clone git 

add authentication to salt:
  file.managed:
    - source: salt://saltgui/templates/external_auth.conf.j2
    - template: jinja
    - name: '/etc/salt/master.d/saltgui_external_auth.conf'

add cherryapi to salt:
  file.managed:
    - source: salt://saltgui/templates/cherryapi.conf.j2 
    - template: jinja
    - name: '/etc/salt/master.d/saltgui_cherryapi.conf'

add saltgui conf:
  file.managed:
    - source: salt://saltgui/templates/saltgui.conf.j2 
    - template: jinja
    - name: '/etc/salt/master.d/saltgui.conf'


saltgui reload salt-api service:
  service.running:
    - name: salt-api
    - enable: true
    - watch:
      - add cherryapi to salt
      - add authentication to salt
      - saltgui packages needed
      - add saltgui conf

{% for user, details in pillar['saltguiusers'].items() %}
add users {{ user }}: 
  user.present:
    - name: {{ user }}
    - hash_password: {{ details.get('hash') }} 
{% endfor %}
