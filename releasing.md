# Dfam TE Tools Release checklist

1. Update included software
  * `getsrc.sh`: downloaded file names
  * `Dockerfile`: paths, checksum
  * `README.md`: "Included software" table
2. Update version number in:
  * `dfam-tetools.sh`: container to run
  * `README.md`: "Included software" heading
3. Build the container (see `README.md`)
  * Use the tag `dfam/tetools:dev`
4. Test the container
5. Commit + tag in git as x.y
6. Tag the container as `:x`, `:x.y`, and `:latest`
7. Push these tags to docker hub
8. Push the commit tag to github
