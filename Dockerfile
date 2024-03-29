# editme: Change this to the BIDS App container
FROM pennbbl/qsiprep:0.12.2 as base

# editme: Change this to your email.
LABEL maintainer="support@flywheel.io"

# Hopefully You won't need to change anything below this.

# Save docker environ here to keep it separate from the Flywheel gear environment
RUN python -c 'import os, json; f = open("/tmp/gear_environ.json", "w"); json.dump(dict(os.environ), f)'

RUN apt-get update && \
    curl -sL https://deb.nodesource.com/setup_10.x | bash - && \
    apt-get install -y \
    zip \
    nodejs \
    tree && \
    rm -rf /var/lib/apt/lists/* && \
    npm install -g bids-validator@1.5.7


# Set CPATH for packages relying on compiled libs (e.g. indexed_gzip)
ENV PATH="/usr/local/miniconda/bin:$PATH" \
    CPATH="/usr/local/miniconda/include/:$CPATH" \
    LANG="C.UTF-8" \
    LC_ALL="C.UTF-8" \
    PYTHONNOUSERSITE=1

# Python 3.8.3 (default, May 19 2020, 18:47:26)
# [GCC 7.3.0] :: Anaconda, Inc. on linux
COPY requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt && \
    rm -rf /root/.cache/pip

ENV FLYWHEEL /flywheel/v0
WORKDIR ${FLYWHEEL}

ENV PYTHONUNBUFFERED 1

COPY manifest.json ${FLYWHEEL}/manifest.json
COPY utils ${FLYWHEEL}/utils
COPY run.py ${FLYWHEEL}/run.py

RUN chmod a+x ${FLYWHEEL}/run.py
ENTRYPOINT ["/flywheel/v0/run.py"]
