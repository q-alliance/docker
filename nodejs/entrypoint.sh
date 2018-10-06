#!/bin/bash

set -e

args="$@"

if [[ "$-" =~ i ]]
then
    # interactive
    /bin/bash --login -i -c "${args}"
else
    # non-interactive
    /bin/bash --login -c "${args}"
fi
