# How to build and run:

1. modify run.sh add your accont credentials
2. inside the folder run the following to build:
```bash
cd src
docker build . -t benchmark-test
```
3. runt the following to run:
```bash
docker run benchmark-test
