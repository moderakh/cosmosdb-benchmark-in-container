#!/bin/bash

operation=$1
concurrency=$2

#if [[ $# -lt 2 ]]; then
#    echo "Illegal number of parameters"
#    exit 2
#fi

if [ -z "$3" ]
then
      connectionMode=Direct
else
      connectionMode=$3
fi

numberOfPreCreatedDocuments=100
consistencyLevel="Eventual"
gatewayConnectionPoolSize=5
#directHttpConnectionPoolSize=4000
numberOfOperations=100000000
protocol=Tcp

colName="testcol2"
dbName="testdb2"

serviceEndpoint="https://moderakh-perf-java.documents.azure.com:443/"
masterKey="XXX"

now=`date -u +"%Y-%m-%dT%H%M%SZ"`
logFileName="$operation-$consistencyLevel-$connectionMode-$protocol-$now.log"
#logFileName="/dev/null"
echo "log file name is $logFileName"

echo "serviceEndpoint $serviceEndpoint, colNmae $colName operation: $operation, consistencyLevel: $consistencyLevel, connectionMode: $connectionMode, protocol: $protocol, concurrency: $concurrency" > $logFileName
start=`test "x$1" == x && date +%s`
#-maxConnectionPoolSize $gatewayConnectionPoolSize 
# -DCOSMOS.MAX_DIRECT_HTTP_CONNECTION_LIMIT=$directHttpConnectionPoolSize 
jar_file=./azure-cosmos-benchmark-4.0.1-beta.1-jar-with-dependencies.jar

#GC_OPT="-XX:+UseConcMarkSweepGC  -XX:+PrintGCDetails -Xloggc:gc.log"
GC_OPT=""
#JVM_OPT="-XX:+PreserveFramePointer"
#JVM_OPT="-Djava.security.properties=~/amazon-corretto-crypto-provider.security"
#JVM_OPT="-Dazure.cosmos.rntbd.threadcount=16 -Dazure.cosmos.rntbd.publishOnScheduler=parallel -Dazure.cosmos.rntbd.subscribeOnScheduler=parallel"
#JVM_OPT="-Dazure.cosmos.rntbd.threadcount=16 -Dazure.cosmos.rntbd.publishOnScheduler=parallel"
JVM_OPT=""
#JVM_OPT='-Dazure.cosmos.rntbd.threadcount=16 -Dazure.cosmos.directTcp.defaultOptions={"maxRequestsPerChannel":10}'
#JVM_OPT="$GC_OPT"
#JVM_OPT="-javaagent:/home/moderakh/allocation-instrumenter/target/java-allocation-instrumenter-3.0-SNAPSHOT.jar=/home/moderakh/inmobi/flame.properties"
#java $JVM_OPT -DCOSMOS.PROTOCOL=$protocol  -jar "$jar_file" -serviceEndpoint "$serviceEndpoint" -masterKey "$masterKey" -databaseId "smallcol2" -collectionId "$colName" -consistencyLevel $consistencyLevel -concurrency $concurrency -numberOfOperations $numberOfOperations -operation $operation -connectionMode $connectionMode -numberOfPreCreatedDocuments $numberOfPreCreatedDocuments -graphiteEndpoint 52.247.208.11 -enableJvmStats 2>&1| tee -a "$logFileName"
#additionalBenchmarkOptions="-disablePassingPartitionKeyAsOptionOnWrite" 
additionalBenchmarkOptions="" 
additionalBenchmarkOptions="-documentDataFieldSize 10 -documentDataFieldCount 10" 
additionalBenchmarkOptions="$additionalBenchmarkOptions -maxConnectionPoolSize $gatewayConnectionPoolSize"

java -Xmx8g -Xms8g  $JVM_OPT -Dcosmos.directModeProtocol=$protocol -Dazure.cosmos.directModeProtocol=$protocol -jar "$jar_file" -serviceEndpoint "$serviceEndpoint" -masterKey "$masterKey" -databaseId "$dbName"  -collectionId "$colName" -consistencyLevel $consistencyLevel -concurrency $concurrency -numberOfOperations $numberOfOperations -operation $operation -connectionMode $connectionMode -numberOfPreCreatedDocuments $numberOfPreCreatedDocuments $additionalBenchmarkOptions 2>&1 | tee -a "$logFileName"

end=`test "x$1" == x && date +%s`
total_time=`expr $end - $start`

echo "It took $total_time seconds to insert $numberOfOperations documents." 
