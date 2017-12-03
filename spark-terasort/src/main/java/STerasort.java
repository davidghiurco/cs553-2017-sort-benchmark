import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

public class STerasort {

    public static void main(String[] args) throws Exception {
        String inputFileName = args[0];
        String outputDir = "/output/spark";
        String hdfs_URI = args[1]; // "localhost:9000"
        int numPartitions = Integer.parseInt(args[2]);

        SparkConf conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sc = new JavaSparkContext(conf);

        JavaRDD<String> textFile = sc.textFile("hdfs://" + hdfs_URI + inputFileName);
        JavaRDD<String> sorted = textFile
                .sortBy((Function<String, String>) value -> value, true, numPartitions);

        sorted.saveAsTextFile("hdfs://" + hdfs_URI + outputDir);
    }
}