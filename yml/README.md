# Migrate configuration

The script automatically compares your configuration file with the default file of a particular version and determines the differences between them. Then, it does a syntax conversion for thingsboard.conf.

2 files are created for convenience. 
- `differences.yml` - shows what was the difference.
- `output.conf` - the variables ready to be exported into your thingsboard.conf file.

To run the script, you must replace the version inside the script or specify it at startup:
```
./custom-config-migrator.sh --version=3.3.4.1
```

By default, the script tries to open the thingsboard.yml file, which is located in the folder next to it. You can override this by specifying the path to the file.
```
./custom-config-migrator.sh --version=3.3.4.1 /usr/share/thingsboard/conf/thingsboard.yml 
````