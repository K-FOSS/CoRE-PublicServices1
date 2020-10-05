# K-FOSS/KJDev-PublicServices1 Swarm Stack

## Usage

There are 3 VMs each with 4 CPUs 24GB RAM 20GB

```
./bin/prepare.sh
```

```
./bin/deploy.sh
```

On each Swarm node install the S3 to Docker volume plugin

```
docker plugin install rexray/s3fs S3FS_OPTIONS="allow_other,use_path_request_style,nonempty,url=http://localhost:8080" S3FS_ENDPOINT="http://localhost:8080" S3FS_ACCESSKEY="BLAH" S3FS_SECRETKEY="BLAHBLAH"
```
