# Steps to serve django apps

1. Containerize the image such that the django project lives in the shared repo.
2. Start with installing the required python3 modules and other dependencies.
3. Ensure the database file is fully accessible.
4. Use the development server to ensure the website gets served properly.
5. From inside the docker container collect the static files of the django web application.

```
# Add this to the bottom of settings.py file
STATIC_ROOT = os.path.join( BASE_DIR, "static" )

python3 manage.py collectstatic
```

6. Now create and enable apache2 virtual host file.

```
<VirtualHost *:80>
    ServerName localhost

    # Serve static files directly through Apache
    Alias /static/ /home/shared/workspace/wealth_tracker/static/
    <Directory /home/shared/workspace/wealth_tracker/static/>
        Require all granted
    </Directory>

    # WSGI configuration (DO NOT use python-home if using system python)
    WSGIDaemonProcess dynamic_django python-path=/home/shared/workspace/wealth_tracker processes=1 threads=1
    WSGIProcessGroup dynamic_django
    WSGIApplicationGroup %{GLOBAL}
    WSGIScriptAlias / /home/shared/workspace/wealth_tracker/config/wsgi.py

    <Directory /home/shared/workspace/wealth_tracker/config>
        <Files wsgi.py>
            Require all granted
        </Files>
    </Directory>
</VirtualHost>

# Now enable the site
sudo a2ensite app.conf
sudo a2dissite 000-default.conf
```