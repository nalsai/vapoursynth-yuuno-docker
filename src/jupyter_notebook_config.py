import os
c = get_config()
c.NotebookApp.ip = '*'
c.NotebookApp.allow_remote_access = True
c.NotebookApp.password = u'argon2:$argon2id$v=19$m=10240,t=10,p=8$wycKI1i7OPqUe9d6wZSMtw$H5Mrk4xrFlwvodarwERke/eLkxGi5qAP2yedPtrCZsw'
c.NotebookApp.port = int(os.environ.get("PORT", 8888))
c.NotebookApp.allow_root = True
c.NotebookApp.allow_password_change = True
c.NotebookApp.open_browser = False
