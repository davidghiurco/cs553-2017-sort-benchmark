import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.PairFunction;
import scala.Tuple2;

import java.util.Arrays;

public class STerasort {

    public static void main(String[] args) throws Exception {
        String inputFileName = "/input/tiny.data";
        String outputFileName = "/output/spark";

        SparkConf conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sc = new JavaSparkContext(conf);

        JavaRDD<String> textFile = sc.textFile("hdfs://MSI-OSBox:9000" + inputFileName);

        JavaRDD<String> sorted = textFile
                .map(line -> line.split(" ", 2))
                .mapToPair(s -> new Tuple2<>(s[0], s[1]))
                .sortByKey()
                .map(tuple -> String.join(" ", tuple._1(), tuple._2()));


        sorted.saveAsTextFile("hdfs://MSI-OSBox:9000" + outputFileName);
    }
}