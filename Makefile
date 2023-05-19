APP=$(shell basename $(shell git remote get-url origin))
REGISTRY=devopsnix
VERSION=$(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS=linux
TARGETARCH=arm64

macos:
	${MAKE} build TARGETOS=darwin TARGETARCH=${TARGETARCH}
linux:
	${MAKE} build TARGETOS=linux TARGETARCH=${TARGETARCH}
windows:
	${MAKE} build TARGETOS=windows TARGETARCH=${TARGETARCH} CGO_ENABLED=1

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get


build: format get
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${shell dpkg --print-architecture} go build -v -o kbot -ldflags "-X="github.com/melnichenkod/kbot/cmd.appVersion=${VERSION}
image:
	docker build . -t ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH} --build-arg CGO_ENABLED=0 --build-arg TARGETARCH=${TARGETARCH} --build-arg TARGETOS=${TARGETOS}
push:
	docker push ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
clean:
	${RM} ./kbot
	docker rmi ${REGISTRY}/${APP}:${VERSION}-${TARGETARCH}
