ARG DEBIAN_VERSION=trixie

FROM debian:${DEBIAN_VERSION}

ARG APP_DIR=/opt/mac-filtering/
ARG SERVICE_USER="unifi-mac-filter"
ARG SERVICE_FILE="/etc/systemd/system/mac-filtering.service"
ARG SERVICE_NAME="mac-filtering"

RUN useradd --system --home-dir "${APP_DIR}" --shell /usr/sbin/nologin "${SERVICE_USER}"

RUN apt-get update && apt-get -y install python3-venv python3-pip unzip git

RUN mkdir -p "${APP_DIR}" && \
    mkdir -p "${APP_DIR}/instance/backups" && \
    chown ${SERVICE_USER}:${SERVICE_USER} "${APP_DIR}/instance/backups"

COPY requirements.txt ${APP_DIR}/

RUN python3 -m venv "${APP_DIR}/.venv" && \
    "${APP_DIR}/.venv/bin/python" -m pip install --upgrade pip wheel && \
    "${APP_DIR}/.venv/bin/python" -m pip install -r "${APP_DIR}/requirements.txt"

COPY . ${APP_DIR}/

RUN cp "${APP_DIR}/.env.example" "${APP_DIR}/.env" && \
    printf '\nAPP_NAME="UniFi MAC Filtering"\n' >> "${APP_DIR}/.env" && \
    chown -R "${SERVICE_USER}:${SERVICE_USER}" "${APP_DIR}" && \
    chmod 600 "${APP_DIR}/.env"


USER ${SERVICE_USER}
WORKDIR ${APP_DIR}
ENTRYPOINT ["/bin/bash", "./entry_point.sh"]
CMD []
