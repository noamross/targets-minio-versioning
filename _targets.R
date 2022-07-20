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
if (try(s3_service$get_bucket_versioning(s3_bucket)$Status) == "Enabled") {
  tar_option_set(resources = tar_resources(
    aws = tar_resources_aws(
      endpoint = s3_endpoint,
      bucket = s3_bucket
    )),
    repository = "aws")
}


# Load any R functions
lapply(list.files("R", full.names = TRUE, recursive = TRUE), source)

# Define some targets
list(
  tar_target(
    name = data,
    command = data.frame(x = rnorm(2000), y = rnorm(2000))
  ),
  tar_target(
    name = model,
    command = coefficients(lm(y ~ x, data = data))
  )
)
