FROM ghcr.io/open-uchile/edx-platform:af3a6340b7d252c4e03d8e397b956a16371b1e7d as base

# Install private requirements: this is useful for installing custom xblocks.
# In particular, to install xblocks from a private repository, clone the
# repositories to ./requirements on the host and add `-e ./myxblock/` to
# ./requirements/private.txt.
COPY ./requirements/ /openedx/requirements
RUN touch /openedx/requirements/private.txt \
    && pip install --src ../venv/src -r /openedx/requirements/private.txt

# Copy themes
COPY ./themes/ /openedx/themes/

# Build static assets
RUN openedx-assets themes \
    # Rebuild translations
    && python manage.py lms --settings=prod.assets compilejsi18n \
    && python manage.py cms --settings=prod.assets compilejsi18n \
    && openedx-assets collect --settings=prod.assets

FROM rclone/rclone:1.53 as s3

COPY --from=base /openedx/staticfiles /data
