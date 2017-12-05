import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.input.PortableDataStream;

import java.io.*;

public class STerasort {

    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.out.println("number of partitions required");
        }

        SparkConf spark_conf = new SparkConf().setAppName("Spark TeraSort");
        JavaSparkContext sparkContext = new JavaSparkContext(spark_conf);


        long startTime = System.nanoTime();
//        JavaRDD<String> textFile = sparkContext.textFile("/input", Integer.parseInt(args[0]));
//        JavaRDD<String> sorted = textFile
//                .sortBy(value -> value, true, Integer.parseInt(args[0]));
//        sorted.saveAsTextFile("/output");


        JavaPairRDD<String, PortableDataStream> binaryFile = sparkContext.binaryFiles("/input");
        JavaPairRDD<String, PortableDataStream> sorted = binaryFile.sortByKey();
        sorted.saveAsObjectFile("/output");


        long endTime = System.nanoTime();
        double duration = (double) (endTime - startTime) / 1000000000.0;

        System.out.println("***************DURATION: " + duration + "s");

//        PrintWriter writer = new PrintWriter("stera_duration.txt", "UTF-8");
//        writer.println(duration);
//        writer.close();
//
//        try (Writer w = new BufferedWriter(new OutputStreamWriter(
//                new FileOutputStream("filename.txt"), "utf-8"))) {
//            w.write("something");
//        }

    }

}