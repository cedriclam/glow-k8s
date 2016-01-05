FROM       golang:1.5
MAINTAINER Cedric Lamoriniere <cedric.lamoriniere@gmail.com>

RUN go get github.com/chrislusf/glow

// Expose 8930 for the glow master mode
EXPOSE 8930
// Expose 8930 for the glow agent mode
EXPOSE 8931

ENTRYPOINT ["glow"]
