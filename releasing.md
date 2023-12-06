# Dfam TE Tools Release checklist
Build location can be changed. https://www.digitalocean.com/community/questions/how-to-move-the-default-var-lib-docker-to-another-directory-for-docker-on-linux 
1. Update included software
  * `getsrc.sh`: downloaded file names
  * `sha256sums.txt`: checksums
      * To update, run: `(cd src; sha256sum *) >sha256sums.txt`
  * `Dockerfile`: paths
  * `README.md`: "Included software" table
  * `CHANGELOG.md`: "Updated" section
2. Update version number in:
  * `dfam-tetools.sh`: container to run
  * `README.md`: "Included software" heading
  * `CHANGELOG.md`: "Unreleased" heading -> version number and date
3. Build the container (see `README.md`)
  * Use the tag `dfam/tetools:dev`
4. Test the container
  * `container_test.sh` will run as the last step of the build
5. Commit and tag in git as x.y
  * run `git tag -a x.y`
6. Tag the container (in docker) as `:x`, `:x.y`, and `:latest`
  * For each version, run: `docker image tag dfam/tetools:dev dfam/tetools:version`
7. Push these tags to docker hub
  * For each tag made before: `docker push dfam/tetools:version`
8. Push the commit and tag to github
9. Generate a release on the github site
  * On the releases tab select "Draft a new release"
  * Choose the tag saved in step 5
  * Use a release title like "Dfam TE Tools x.y"
  * Use a description like "See the CHANGELOG for details."
  * Set as the "latest release"
  * Click on "Publish release" 
