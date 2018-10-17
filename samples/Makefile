.PHONY: all build-parse-sample tcp-sample clean

all: NatsPubSub

NatsSubscribe:
	make -C NatsSubscribe

NatsPubSub:
	make -C NatsPubSub

clean:
	make -C NatsSubscribe clean
	make -C NatsPubSub clean
