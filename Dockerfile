FROM golang:1.9 AS builder

WORKDIR /go/src/github.com/tanner-bruce/apache_exporter

COPY vendor ./vendor
COPY apache_exporter.go ./

RUN env GO15VENDOREXPERIMENT=1 \
        CGO_ENABLED=0 \
        GOOS=linux \
        GOARCH=amd64 \
    go build -o apache_exporter apache_exporter.go \
    && cp ./apache_exporter /apache_exporter \
    && unset HTTP_PROXY HTTPS_PROXY NO_PROXY DO_UPGRADE http_proxy https_proxy

FROM scratch

# Apache Exporter image for OpenShift Origin

LABEL io.k8s.description="Apache Prometheus Exporter." \
      io.k8s.display-name="Apache Exporter" \
      io.openshift.expose-services="9113:http" \
      io.openshift.tags="apache,exporter,prometheus" \
      io.openshift.non-scalable="true" \
      help="For more information visit https://github.com/Worteks/docker-httpexporter" \
      maintainer="Samuel MARTIN MORO <faust64@gmail.com>" \
      version="1.0"

COPY --from=builder /apache_exporter /apache_exporter

ENTRYPOINT ["/apache_exporter"]
