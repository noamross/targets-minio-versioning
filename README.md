
# targets-minio-versioning

The goal of targets-minio-versioning is to ...


# Startup


 - Clone this repository




```R
renv::restore()
piggyback::
```

- Install minio server. Follow instructions for your OS at <https://docs.min.io/minio/baremetal/quickstart/quickstart.html>


Run the min.io server:
```r
mserver <- processx::process$new(
  command = "minio", args = c("server", "minio_storage", "--console-address", "localhost:9090"),
  stdout = "", stderr = "2>&1"
)
``

Visit the web intervace for your min.io server at <http://localhost:9090/>.  The default login
and password are both `minioadmin`.  You can set these with 'MINIO_ROOT_USER' and 'MINIO_ROOT_PASSWORD' environment variables.
Log in and create a bucket (called "targets_versioning" here) with versioning turned on.

Then go to `Identity > Service Accounts` and create a new set of credentials.  Here I use `testcreds` for both username and password.

If you grab the directory and start the server, the bucket and service account credentials will already be created. (They are stored under `minio_storage/.minio.sys/`)


