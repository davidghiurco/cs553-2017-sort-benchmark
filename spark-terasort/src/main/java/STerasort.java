import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.SparkConf;
import scala.Tuple2;

import java.util.Arrays;

public class STerasort {
    SparkConf conf = new SparkConf().setAppName("Spark TeraSort");

    JavaSparkContext sc = new JavaSparkContext(conf);

    JavaRDD<String> file = sc.textFile("");


    JavaRDD<String> textFile = sc.textFile("hdfs://...");
    JavaPairRDD<String, Integer> counts = textFile
            .flatMap(s -> Arrays.asList(s.split(" ")).iterator())
            .mapToPair(word -> new Tuple2<>(word, 1))
            .reduceByKey((a, b) -> a + b);
    counts.saveAsTextFile("hdfs://...");
}