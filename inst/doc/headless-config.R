## ----setup--------------------------------------------------------------------
library(rlmstudio)
lms_installed <- has_lms()

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----check-status-------------------------------------------------------------
# Verify the CLI is available before proceeding
has_lms()

## ----start-daemon, eval=lms_installed-----------------------------------------
# Start the headless engine in the background
lms_daemon_start()

## ----start-server, eval=lms_installed-----------------------------------------
# Start the local server on the default port
lms_server_start()

## ----download, eval=lms_installed---------------------------------------------
# Download a model using its identifier
job_id <- lms_download("qwen/qwen3-4b-2507")
lms_download_status(job_id)

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

## ----list, eval=lms_installed-------------------------------------------------
# View all downloaded models
models <- list_models()

# Filter for unloaded text models
unloaded_llms <- models |>
  subset(type == "llm" & state == "unloaded")
unloaded_llms

## ----load, eval=lms_installed-------------------------------------------------
# Load the model
lms_load("google/gemma-3-1b", flash_attention = TRUE)

## ----chat, eval=lms_installed-------------------------------------------------
response <- lms_chat(
  model = "google/gemma-3-1b",
  input = "Provide just the str_extract() pattern to match all text after the third comma.",
  system_prompt = "You are an expert R programmer familiar with the tidyverse."
)

cat(response)

## ----teardown, eval=lms_installed---------------------------------------------
# 1. Unload the model from memory
lms_unload("google/gemma-3-1b")

# 2. Stop the API server
lms_server_stop()

# 3. Stop the background daemon
lms_daemon_stop()

## ----with-daemon, eval=lms_installed------------------------------------------
# The daemon will start, the code will run, and the daemon will stop on exit.
results <- with_lms_daemon({
  lms_server_start()
  lms_load("google/gemma-3-1b")

  res <- lms_chat("google/gemma-3-1b", "Is the daemon running?")

  lms_server_stop()
  res
})

