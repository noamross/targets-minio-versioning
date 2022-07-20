
# targets-minio-versioning

[![License (for code):
MIT](https://img.shields.io/badge/License%20(for%20code)-MIT-green.svg)](https://opensource.org/licenses/MIT)

This repo is a demonstration of using the R [`{targets}`](https://books.ropensci.org/targets/)
framework along with the [min.io](https://min.io/) S3-compatible server to have
linked version control between code, data, and code-generated objects.

`{targets}` can use AWS S3 storage to store objects generated, and with S3 bucket
versioning enabled, [it can store all versions of targets](https://books.ropensci.org/targets/data.html#data-version-control).
If you then version the `_targets/meta/meta` with your code, targets will fetch
object versions matching your code.

However, for cost, security, or connectivity reasons, it may not make sense to
store your data on AWS.  [min.io](https://min.io/) is an open-source, free
server that serves files over an S3-compatible REST interface.  You can run
it on your own server within an organization network or locally on your machine.

This repo demonstrates using min.io for versioning on your local machine.

# Startup

-   Install minio server. Follow instructions for your OS at <https://docs.min.io/minio/baremetal/quickstart/quickstart.html>. It's just a `brew`, `apt`, or binary download.
-   Clone this repository
-   Bootstrap packages and data.  Start a session and run:

    ```R
    renv::restore() # Install relevant packages
    piggyback::pb_download("minio_storage.zip") # Fetch the min.io data
    unzip("minio_stroage.zip")
    ```
    This creates a `minio_storage` folder (gitignore'd) which will contain the 
    contents of your local S3 bucket

Now, start a min.io server:

```r
mserver <- processx::process$new(
  command = "minio", args = c("server", "minio_storage", "--console-address", "localhost:9090"),
  stdout = "", stderr = "2>&1"
)
``

This serves an S3 endpoint at local port 9000. You can the web interace for your min.io server at <http://localhost:9090/>.  The default login
and password are both `minioadmin`.  In this case, the server alread has a bucket  with versioning turned on ("targets-versioned"), and a set of credentials ("testcreds"/"testcreds")

If you were starting your own new project, you could admin credentials with 'MINIO_ROOT_USER' and 'MINIO_ROOT_PASSWORD' environment variables, create your own bucket, and create a more secure set of credentials under `Identity > Service Accounts`.

In the `_targets.R` file, which defines the project workflow, we use `tar_option_set()` to 
use the local min.io S3 endpoint and the "targets-versioned" bucket to store all our 
objects.

Now, build your projects in the R console:

```
targets::tar_make()

```

All targets should be skipped and the pipeline should be complete.

We can do the same moving to a different commit.  In the shell, go to an old
version of the code:

```bash
git checkout 
```

Now run `targets::tar_make()` again.  The targets should still skip! 


Return to the HEAD:

```bash
git checkout HEAD
```

Now you can try modifying the `_targets.R` pipeline, building and committing 
`_targets/meta/meta`.  That file stores references to the  AWS files and versions
served by the min.io server:

Stop your server when you are done:

```r
mserver$kill()
```

If you also want to share your targets data via piggyback, you can pull and push
it like so. You'll nee

```
zip("minio_storage.zip", list.files("minio_storage", recursive=TRUE, all.files = TRUE, full.names = TRUE))
piggyback::pb_new_release(repo = "YOUR_NAMESPACE/YOUR_REPO", "YOUR_TAG") # Only need to do this once
piggyback::pb_upload("minio_storage.zip", repo = "YOUR_NAMESPACE/YOUR_REPO")
```

`piggyback` attaches the data to GitHub releases and this has a 2GB size limit. 
As the storage directory stores every version of your objects, it can get quite large and it may not
be practical to share it this way.  You can prune your versions via the `min.io` web
interface.

However, if you have a shared server, you can use `min.io` on it so your
team can share object versions without pushing or pulling.
