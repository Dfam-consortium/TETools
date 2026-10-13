# Dfam TE Tools Release checklist
Build location can be changed. https://www.digitalocean.com/community/questions/how-to-move-the-default-var-lib-docker-to-another-directory-for-docker-on-linux 
1. Update included software
  * Edit `getsrc.sh`: downloaded file names
      * Remember to update `Dfam-RepeatMasker.lib.gz` path when Dfam release changes 
      * After editing run the script to update the src/ subdirectory.
      * Remove outdated packages from the src/ subdirectory.
  * `sha256sums.txt`: checksums
      * To update, run: `(cd src; sha256sum *) >sha256sums.txt`
  * Edit `Dockerfile`: paths
  * `README.md`: "Included software" table
  * `CHANGELOG.md`: "Updated" section
2. Update version number in:
  * `dfam-tetools.sh`: container to run
  * `README.md`: "Included software" heading
3. Build the container (see `README.md`)
  * Use the tag `dfam/tetools:dev`
  * `docker build -t dfam/tetools:dev .`
4. Test the container
  * `container_test.sh`
<!-- 5. Build the multiplatform container if possible 
  * ` docker buildx build --platform=linux/amd64,linux/arm64 --output=type=registry -t dfam/tetools:dev .`
6. Pull complete container 
  * `docker pull dfam/tetools:dev` -->
7. Commit and tag in git as x.y
  * run `git commit -a -m "Release x.y"`
  * run `git tag -a <x.y>`
  * For example, if the new version is 1.97 then use `git tag -a 1.97`
8. Tag the container (in docker) as `:x`, `:x.y`, and `:latest`
  * For each version, run: `docker image tag dfam/tetools:dev dfam/tetools:<version>`
  * For example, if the new version is 1.97 then: `docker image tag dfam/tetools:dev dfam/tetools:1` and then `docker image tag dfam/tetools:dev dfam/tetools:1.97` and then `docker image tag dfam/tetools:dev dfam/tetools:latest`
9. Push these tags to docker hub
  * For each tag made before: `docker push dfam/tetools:<version>`
  * For example, if the new version is 1.97 then: `docker push dfam/tetools:1`, `docker push dfam/tetools:1.97`, and `docker push dfam/tetools:latest`
  * Multiplatform: `docker buildx imagetools create --tag dfam/tetools:<new tag> dfam/tetools:dev`
10. Push the commit and tag to github
  * run `git push origin <x.y>`
11. Generate a release on the github site
  * On the releases tab select "Draft a new release"
  * Choose the tag saved in step 5
  * Use a release title like "Dfam TE Tools x.y"
  * Use a description like "See the CHANGELOG for details."
  * Set as the "latest release"
  * Click on "Publish release" 
