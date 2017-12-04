import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.examples.terasort.TeraInputFormat;
import org.apache.hadoop.examples.terasort.TeraOutputFormat;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;

public class STerasort {

    public static void main(String[] args) throws Exception {
//        if (args.length != 4) {
//            usage();
//            System.exit(1);
//        }
//
//        String inputFileName = args[0];
//        String outputDir = args[1];
//        String hdfs_URI = args[2]; // "localhost:9000"
//        int numPartitions = Integer.parseInt(args[3]);

        // Hadoop setup
        Configuration hadoop_conf = new Configuration();
        Job job = Job.getInstance(hadoop_conf, "STerasort");

        // Input
        FileInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TeraInputFormat.class);

        // Output
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.setOutputFormatClass(TeraOutputFormat.class);


        SparkConf spark_conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sc = new JavaSparkContext(spark_conf);



//        JavaRDD<String> textFile = sc.textFile("hdfs://" + hdfs_URI + inputFileName);
//        JavaRDD<String> sorted = textFile
//                .sortBy((Function<String, String>) value -> value, true, numPartitions);
//        sorted.saveAsTextFile("hdfs://" + hdfs_URI + outputDir);
        JavaPairRDD<Text, Text> rdd = sc.newAPIHadoopRDD(hadoop_conf, TeraInputFormat.class, Text.class, Text.class);
        JavaPairRDD<Text, Text> sort = rdd.sortByKey();
        sort.saveAsNewAPIHadoopDataset(hadoop_conf);

    }

    private static void usage() {
        System.out.println("stera.jar <HDFS-input-dir> <HDFS-output-dir> <HDFS Master URI> <numPartitions>");
        System.out.println("<HDFS-input-dir>: Example: '/input/file.dat'");
        System.out.println("<HDFS-output-dir>: Example: '/output'");
        System.out.println("<HDFS Master URI>: Example 'localhost:9000'");
        System.out.println("<numPartitions>: Level of Spark RDD parallelism");
    }
}