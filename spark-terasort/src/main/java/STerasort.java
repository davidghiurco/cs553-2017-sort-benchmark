import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

public class STerasort {

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.out.println("number of partitions required");
        }

        SparkConf spark_conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sparkContext = new JavaSparkContext(spark_conf);

        JavaRDD<String> textFile = sparkContext.textFile("/input");
        JavaRDD<String> sorted = textFile
                .sortBy((Function<String, String>) value -> value, true, Integer.parseInt(args[0]));
        sorted.saveAsTextFile("/output");

        sparkContext.stop();

    }

}