#
# Salt state to configure the yum-cron service from external
# data sources (Pillar and grains) and then ensure service has
# been (re)started
#
#################################################################

{%- set this_host = salt['grains.get']('fqdn') %}


{%- if salt['grains.get']('osmajorrelease') == '6' %}
{%- set update_struct = salt['pillar.get']('yum-cron:update-behavior:el6', None) %}
{%- set cfgFile = '/etc/sysconfig/yum-cron' %}
file-{{ cfgFile }}-exists:
  file.exists:
    - name: '{{ cfgFile }}'

file-{{ cfgFile }}-YumParm:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^YUM_PARAMETER=.*'
    - repl: YUM_PARAMETER= {{ update_struct.get('yum-parm', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-CheckOnly:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^CHECK_ONLY=.*'
    - repl: CHECK_ONLY={{ update_struct.get('check-only', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-CheckFirst:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^CHECK_FIRST=.*'
    - repl: CHECK_FIRST={{ update_struct.get('check-first', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-DownloadOnly:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^DOWNLOAD_ONLY=.*'
    - repl: DOWNLOAD_ONLY={{ update_struct.get('download-only', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-ErrorLevel:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^ERROR_LEVEL=.*'
    - repl: ERROR_LEVEL={{ update_struct.get('error-level', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-DebugLevel:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^DEBUG_LEVEL=.*'
    - repl: DEBUG_LEVEL={{ update_struct.get('debug-level', '') }}
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-RandWait:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^RANDOMWAIT=.*'
    - repl: RANDOMWAIT="{{ update_struct.get('randwait', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-MailTo:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^MAILTO=.*'
    - repl: MAILTO="{{ update_struct.get('email-to', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-SysName:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^SYSTEMNAME=.*'
    - repl: SYSTEMNAME="{{ this_host }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-WeekDays:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^DAYS_OF_WEEK=.*'
    - repl: DAYS_OF_WEEK="{{ update_struct.get('dayofweek', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-CleanDay:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^CLEANDAY=.*'
    - repl: CLEANDAY="{{ update_struct.get('cleanday', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-SvcWaits:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^SERVICE_WAITS=.*'
    - repl: SERVICE_WAITS="{{ update_struct.get('svc-waits', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

file-{{ cfgFile }}-SvcWaitTime:
  file.replace:
    - name: '{{ cfgFile }}'
    - pattern: '^SERVICE_WAIT_TIME=.*'
    - repl: SERVICE_WAIT_TIME="{{ update_struct.get('svc-wait-time', '') }}"
    - append_if_not_found : True
    - require:
      - file: file-{{ cfgFile }}-exists

svc-yum_cron-running:
  service.running:
    - name: 'yum-cron'
    - enable: True
    - watch:
      - file: '{{ cfgFile }}'

{%- elif salt['grains.get']('osmajorrelease') == '7' %}
{%- set update_struct = salt['pillar.get']('yum-cron:update-behavior:el7', None) %}
{%- set rootFile = '/etc/yum/yum-cron' %}
{%- set cfgFile = rootFile + '.conf' %}
{%- set hourlyFile = rootFile + '-hourly.conf' %}
file-{{ cfgFile }}-exists:
  file.managed:
    - name: '{{ cfgFile }}'
    - backup: True
    - create: False
    - contents: |
        [commands]
        #  What kind of update to use:
        update_cmd = default
        
        # Whether a message should be emitted when updates are available,
        # were downloaded, or applied.
        update_messages = yes
        
        # Whether updates should be downloaded when they are available.
        download_updates = yes
        
        # Whether updates should be applied when they are available.  Note
        # that download_updates must also be yes for the update to be applied.
        apply_updates = no
        
        # Maximum amout of time to randomly sleep, in minutes.  The program
        # will sleep for a random amount of time between 0 and random_sleep
        # minutes before running.  This is useful for e.g. staggering the
        # times that multiple systems will access update servers.  If
        # random_sleep is 0 or negative, the program will run immediately.
        # 6*60 = 360
        random_sleep = 360
        
        [emitters]
        # Name to use for this system in messages that are emitted.  If
        # system_name is None, the hostname will be used.
        system_name = {{ this_host }}
        
        # How to send messages.  Valid options are stdio and email.  If
        # emit_via includes stdio, messages will be sent to stdout; this is useful
        # to have cron send the messages.  If emit_via includes email, this
        # program will send email itself according to the configured options.
        # If emit_via is None or left blank, no messages will be sent.
        emit_via = stdio
        
        # The width, in characters, that messages that are emitted should be
        # formatted to.
        ouput_width = 80
        
        [groups]
        # NOTE: This only works when group_command != objects, which is now the default
        # List of groups to update
        group_list = None
        
        # The types of group packages to install
        group_package_types = mandatory, default
        
        [base]
        
        # Use this to filter Yum core messages
        # -4: critical
        # -3: critical+errors
        # -2: critical+errors+warnings (default)
        debuglevel = -2
        
        # skip_broken = True
        mdpolicy = group:main
        
        # Uncomment to auto-import new gpg keys (dangerous)
        # assumeyes = True
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - pkg: 'yum-cron'

file-{{ hourlyFile }}-exists:
  file.managed:
    - name: '{{ hourlyFile }}'
    - backup: True
    - create: False
    - contents: |
        [commands]
        #  What kind of update to use:
        update_cmd = default
        
        # Whether a message should be emitted when updates are available,
        # were downloaded, or applied.
        update_messages = yes
        
        # Whether updates should be downloaded when they are available.
        download_updates = no
        
        # Whether updates should be applied when they are available.  Note
        # that download_updates must also be yes for the update to be applied.
        apply_updates = no
        
        # Maximum amout of time to randomly sleep, in minutes.  The program
        # will sleep for a random amount of time between 0 and random_sleep
        # minutes before running.  This is useful for e.g. staggering the
        # times that multiple systems will access update servers.  If
        # random_sleep is 0 or negative, the program will run immediately.
        # 6*60 = 360
        random_sleep = 360
        
        [emitters]
        # Name to use for this system in messages that are emitted.  If
        # system_name is None, the hostname will be used.
        system_name = {{ this_host }}
        
        # How to send messages.  Valid options are stdio and email.  If
        # emit_via includes stdio, messages will be sent to stdout; this is useful
        # to have cron send the messages.  If emit_via includes email, this
        # program will send email itself according to the configured options.
        # If emit_via is None or left blank, no messages will be sent.
        emit_via = stdio
        
        # The width, in characters, that messages that are emitted should be
        # formatted to.
        ouput_width = 80

        [email]
        # The address to send email messages from.
        # NOTE: 'localhost' will be replaced with the value of system_name.
        email_from = root
        
        # List of addresses to send messages to.
        email_to = root
        
        # Name of the host to connect to to send email messages.
        email_host = localhost
        
        [groups]
        # NOTE: This only works when group_command != objects, which is now the default
        # List of groups to update
        group_list = None
        
        # The types of group packages to install
        group_package_types = mandatory, default
        
        [base]
        
        # Use this to filter Yum core messages
        # -4: critical
        # -3: critical+errors
        # -2: critical+errors+warnings (default)
        debuglevel = -2
        
        # skip_broken = True
        mdpolicy = group:main
        
        # Uncomment to auto-import new gpg keys (dangerous)
        # assumeyes = True
    - user: 'root'
    - group: 'root'
    - mode: '0644'
    - require:
      - pkg: 'yum-cron'

{%- endif %}

