build:
	docker build -t mathtin/hadoop-base:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-base:latest ./base
	docker build -t mathtin/hadoop-namenode:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-namenode:latest ./namenode
	docker build -t mathtin/hadoop-datanode:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-datanode:latest ./datanode
	docker build -t mathtin/hadoop-resourcemanager:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-resourcemanager:latest ./resourcemanager
	docker build -t mathtin/hadoop-nodemanager:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-nodemanager:latest ./nodemanager
	docker build -t mathtin/hadoop-historyserver:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8 -t mathtin/hadoop-historyserver:latest ./historyserver
	docker build -t mathtin/hive:3.1.2-hadoop3.3.1-postgres14 -t mathtin/hive:latest ./hive
	docker build -t mathtin/hadoop-vpn:latest ./vpn
	docker build -t mathtin/hadoop-index:latest ./index
	docker build -t mathtin/flink:1.13.2-hadoop3.3.1-scala_2.11 -t mathtin/flink:latest ./flink

image-push:
	docker image push mathtin/hadoop-base:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-base:latest
	docker image push mathtin/hadoop-namenode:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-namenode:latest
	docker image push mathtin/hadoop-datanode:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-datanode:latest
	docker image push mathtin/hadoop-resourcemanager:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-resourcemanager:latest
	docker image push mathtin/hadoop-nodemanager:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-nodemanager:latest
	docker image push mathtin/hadoop-historyserver:spark3.2.0-hive3.1.2-hadoop3.3.1-scala2.13-java8
	docker image push mathtin/hadoop-historyserver:latest
	docker image push mathtin/hive:3.1.2-hadoop3.3.1-postgres14
	docker image push mathtin/hive:latest
	docker image push mathtin/hadoop-vpn:latest
	docker image push mathtin/hadoop-index:latest
	docker image push mathtin/flink:1.13.2-hadoop3.3.1-scala_2.11
	docker image push mathtin/flink:latest

rebuild-cluster:
	docker-compose down
	make build
	docker-compose up -d

up:
	docker-compose up -d

down:
	docker-compose down
