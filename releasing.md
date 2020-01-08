# Dfam TE Tools Release checklist

1. Update included software
  * `getsrc.sh`: downloaded file names
  * `Dockerfile`: paths, checksum
  * `README.md`: "Included software" table
  * `CHANGELOG.md`: "Updated" section
2. Update version number in:
  * `dfam-tetools.sh`: container to run
  * `README.md`: "Included software" heading
  * `CHANGELOG.md`: "Unreleased" heading -> version number and date
3. Build the container (see `README.md`)
  * Use the tag `dfam/tetools:dev`
4. Test the container
5. Commit and tag in git as x.y
6. Tag the container (in docker) as `:x`, `:x.y`, and `:latest`
7. Push these tags to docker hub
8. Push the commit tag to github
