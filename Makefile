export CONFIG_PATH="C:/Users/chinc/proglog/"

.PHONY: init
init:
	mkdir -p ${CONFIG_PATH}

copy_model:
	cp test/model.conf $(CONFIG_PATH)/model.conf

copy_policy:
	cp test/policy.csv $(CONFIG_PATH)/policy.csv

.PHONY: test
test: copy_policy copy_model
	go test -race ./...

.PHONY: gencert
gencert:
	cfssl gencert \
	-initca test/ca-csr.json | cfssljson -bare ca

	cfssl gencert \
	-ca=ca.pem \
	-ca-key=ca-key.pem \
	-config=test/ca-config.json \
	-profile=server \
	test/server-csr.json | cfssljson -bare server

	cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=test/ca-config.json \
    -profile=client \
    -cn="root" \
    test/client-csr.json | cfssljson -bare root-client

	cfssl gencert \
    -ca=ca.pem \
    -ca-key=ca-key.pem \
    -config=test/ca-config.json \
    -profile=client \
    -cn="nobody" \
    test/client-csr.json | cfssljson -bare nobody-client

	mv *.pem *.csr ${CONFIG_PATH}


.PHONY: compile
compile:
	protoc api/v1/*.proto \
     --go_out=. \
     --go-grpc_out=. \
     --go_opt=paths=source_relative \
     --go-grpc_opt=paths=source_relative \
     --proto_path=.

TAG ?= 0.0.1
build-docker:
	docker build -t github.com/marcusbello/proglog:$(TAG) .