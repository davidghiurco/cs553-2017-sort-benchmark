import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class STerasort {

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.out.println("number of partitions required");
        }

        SparkConf spark_conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sparkContext = new JavaSparkContext(spark_conf);


        long startTime = System.nanoTime();
        JavaRDD<String> textFile = sparkContext.textFile("/input", Integer.parseInt(args[0]));
        JavaRDD<String> sorted = textFile
                .sortBy(value -> value, true, Integer.parseInt(args[0]));
        sorted.saveAsTextFile("/output");


        long endTime = System.nanoTime();
        double duration = (double) (endTime - startTime) / 1000000000.0;

        System.out.println("***************DURATION: " + duration + "s");


    }

}