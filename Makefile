latest: Dockerfile
	docker build --no-cache -t pennoser/production .
	echo "Source docker_start.sh in profile"
