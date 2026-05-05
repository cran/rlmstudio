## ----setup--------------------------------------------------------------------
library(rlmstudio)
lms_installed <- has_lms()

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----check-status-------------------------------------------------------------
# Check if LM Studio is available on this system
has_lms()

## ----start-server, eval=lms_installed-----------------------------------------
# Start the local server on the default port
lms_server_start()
#> ✔ LM Studio server started successfully on the default port.

## ----download, eval=lms_installed---------------------------------------------
# Download a model using its identifier
model <- "google/gemma-3-1b"
job_id <- lms_download(model)
#> ✔ Initiating download for model: "google/gemma-3-1b"... [973ms]
#> ✔ Download job started successfully. Job ID: "job_02c8a1f86e"

lms_download_status(job_id)
#> ── Download Job: "job_02c8a1f86e"
#> Status: completed
#> Progress: 100% (0.72 GB / 0.72 GB)

## ----wait, echo=FALSE, eval=lms_installed-------------------------------------
if (job_id != "already_downloaded") {
  repeat {
    res <- lms_download_status(job_id)
    if (res$status %in% c("completed", "failed", "error")) {
      break
    }
    Sys.sleep(3)
  }
  if (res$status != "completed") {
    cli::cli_abort("Model download failed.")
  }
}

## ----load, eval=lms_installed-------------------------------------------------
# Standard load
lms_load(model, flash_attention = TRUE)
#> ✔ Model "google/gemma-3-1b" loaded and verified. [30.8s]

## ----simple-chat, eval=lms_installed------------------------------------------
response <- lms_chat(
  model = model,
  input = "Say hello!",
  system_prompt = "Answer in rhymes."
)

cat(response)
#> A friendly face, so bright and new,
#> Hello there, it’s waiting for you!
#>
#> Let's chat and have a joyful spree,
#> Hello there, happy as can be!

## ----teardown, eval=lms_installed---------------------------------------------
# Unload the model
lms_unload(model)
#> ✔ Model "google/gemma-3-1b" unloaded successfully. [431ms]

# Stop the server
lms_server_stop()
#> ✔ LM Studio server stopped successfully.

