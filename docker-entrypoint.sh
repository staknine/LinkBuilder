#!/bin/sh
set -e

# Run the migration first using the custom release task
bin/link_builder eval "Release.migrate"

# Launch the OTP release and replace the caller as Process #1 in the container
exec bin/link_builder "$@"
