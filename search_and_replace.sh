#!/bin/bash

set -eou pipefail

# -----------------------------------------------------------------------------
# Parse and Validate Inputs
# -----------------------------------------------------------------------------
eval "$(jq -r '@sh "INPUT_FILE=\(.input_file) OUTPUT_FILE=\(.output_file) SEARCH_TEXT=\(.search_text) REPLACE_TEXT=\(.replace_text)"')"

if [ -z "${INPUT_FILE}" ]; then
  >&2 echo "input_file must be specified and it must point to an existing file."
  exit 1
elif [ ! -f "${INPUT_FILE}" ]; then
  >&2 echo "input_file (${INPUT_FILE}) must point to an existing file."
  exit 2
elif [ -z "${OUTPUT_FILE}" ]; then
  >&2 echo "output_file must be specified."
  exit 3
elif [ -z "${SEARCH_TEXT}" ]; then
  >&2 echo "search_text must be specified."
  exit 4
elif [ -z "${REPLACE_TEXT}" ]; then
  >&2 echo "search_text must be specified."
  exit 5
fi

# -----------------------------------------------------------------------------
# Use SED to run search and replace and return output file for downstream
# resources to bind to.
# -----------------------------------------------------------------------------
sed "s#${SEARCH_TEXT}#${REPLACE_TEXT}#g" ${INPUT_FILE} > ${OUTPUT_FILE}
echo "{ \"output_file\": \"${OUTPUT_FILE}\" }"
exit 0
