.PHONY: all toolkit samples clean

all: toolkit doc

toolkit:
	#make -C com.ibm.streamsx.nats impl || exit 1
	make -C com.ibm.streamsx.nats toolkit || exit 1

doc:
	make -C com.ibm.streamsx.nats doc || exit 1

samples:
	make -C samples || exit 1

clean:
	make -C samples clean
	make -C com.ibm.streamsx.nats clean
