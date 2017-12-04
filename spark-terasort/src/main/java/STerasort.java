import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

public class STerasort {

    public static void main(String[] args) throws Exception {
        if (args.length != 4) {
            usage();
            System.exit(1);
        }

        String inputFileName = args[0];
        String outputDir = args[1];
        String hdfs_URI = args[2]; // "localhost:9000"
        int numPartitions = Integer.parseInt(args[3]);

        SparkConf conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sc = new JavaSparkContext(conf);

        JavaRDD<String> textFile = sc.textFile("hdfs://" + hdfs_URI + inputFileName);
        JavaRDD<String> sorted = textFile
                .sortBy((Function<String, String>) value -> value, true, numPartitions);

        sorted.saveAsTextFile("hdfs://" + hdfs_URI + outputDir);
    }

    private static void usage() {
        System.out.println("stera.jar <HDFS-input-dir> <HDFS-output-dir> <HDFS Master URI> <numPartitions>");
        System.out.println("<HDFS-input-dir>: Example: '/input/file.dat'");
        System.out.println("<HDFS-output-dir>: Example: '/output'");
        System.out.println("<HDFS Master URI>: Example 'localhost:9000'");
        System.out.println("<numPartitions>: Level of Spark RDD parallelism");
    }
}