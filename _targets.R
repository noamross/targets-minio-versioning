# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline # nolint

# Load packages required to define the pipeline:
library(targets)

# If the min.io server is running, use it for storage:
s3_endpoint <- "http://127.0.0.1:9000"
s3_bucket = "targets-versioned"
Sys.setenv(
  AWS_ACCESS_KEY_ID = "testcreds",
  AWS_SECRET_ACCESS_KEY = "testcreds"
)
s3_service <- paws::s3(
  config =
    list(endpoint = s3_endpoint,
         credentials = list(
           creds = list(
             access_key_id = Sys.getenv("AWS_ACCESS_KEY_ID"),
             secret_access_key = Sys.getenv("AWS_SECRET_ACCESS_KEY")
           ))))

cat(s3_service$get_bucket_versioning(s3_bucket)$Status)
if (s3_service$get_bucket_versioning(s3_bucket)$Status == "Enabled") {
  tar_option_set(resources = tar_resources(
    aws = tar_resources_aws(
      endpoint = s3_endpoint,
      bucket = s3_bucket
    )),
    repository = "aws")
}


# tar_make_future() configuration (okay to leave alone):
# Install packages {{future}}, {{future.callr}}, and {{future.batchtools}} to allow use_targets() to configure tar_make_future() options.

lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)

# Replace the target list below with your own:
list(
  tar_target(
    name = data,
    command = data.frame(x = rnorm(100), y = rnorm(100))
    #   format = "feather" # efficient storage of large data frames # nolint
  ),
  tar_target(
    name = model,
    command = coefficients(lm(y ~ x, data = data))
  )
)
