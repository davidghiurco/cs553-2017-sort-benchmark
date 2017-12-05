import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.spark.SparkConf;
import org.apache.spark.SparkContext;
import org.apache.spark.api.java.JavaNewHadoopRDD;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.rdd.NewHadoopRDD;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.examples.terasort.TeraInputFormat;
import org.apache.hadoop.examples.terasort.TeraOutputFormat;
import org.apache.hadoop.examples.terasort.TeraSort;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;

import scala.reflect.ClassTag;

public class STerasort {

    public static void main(String[] args) throws Exception {

        SparkConf spark_conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sparkContext = new JavaSparkContext(spark_conf);

        SparkContext sparkContext1 = new SparkContext(spark_conf);

        // Hadoop setup
        Configuration hadoop_conf = sparkContext.hadoopConfiguration();
        Job job = Job.getInstance(hadoop_conf, "STerasort");

        // Input
        TeraInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TeraInputFormat.class);

        // Output
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.setOutputFormatClass(TeraOutputFormat.class);

//        JavaRDD<String> textFile = sc.textFile("hdfs://" + hdfs_URI + inputFileName);
//        JavaRDD<String> sorted = textFile
//                .sortBy((Function<String, String>) value -> value, true, numPartitions);
//        sorted.saveAsTextFile("hdfs://" + hdfs_URI + outputDir);
//        NewHadoopRDD<Text, Text> srdd = new NewHadoopRDD<>(
//                sparkContext1,
//                TeraInputFormat.class,
//                Text.class,
//                Text.class,
//                hadoop_conf
//        );

//        JavaNewHadoopRDD<Text, Text> rdd = new JavaNewHadoopRDD<Text, Text>(
//                srdd,
//                new ClassTag<Text>(),
//                new ClassTag<Text>()
//        );

//        JavaPairRDD<Text, Text> rdd = NewHadoopRDD(
//                sparkContext, TeraInputFormat.class, Text.class, Text.class, job.getConfiguration())

        JavaPairRDD<Text, Text> rdd = sparkContext.newAPIHadoopRDD(
                hadoop_conf,
                TeraInputFormat.class,
                Text.class,
                Text.class
        );

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