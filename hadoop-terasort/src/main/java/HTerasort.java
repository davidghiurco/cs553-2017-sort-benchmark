import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.examples.terasort.TeraInputFormat;
import org.apache.hadoop.examples.terasort.TeraOutputFormat;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

import java.io.IOException;
import java.io.PrintWriter;


public class HTerasort extends Configured implements Tool {


    public static class SortMapper extends Mapper<Object, Text, Text, NullWritable>{
        private NullWritable nullValue = NullWritable.get();


        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            context.write(value, nullValue);
        }
    }

    // Sorting happens in the shuffle phase, thus the reducer just has to output the key-value pairs

    public static class SortReducer extends Reducer<Text, NullWritable, Text, NullWritable> {
        public void reduce(Text key, Iterable<NullWritable> num_occurrences, Context context) throws IOException, InterruptedException {
            for (NullWritable nullValue : num_occurrences) {
                context.write(key, nullValue);
            }
        }
    }

    private static void usage() throws IOException {
        System.err.println("htera.jar <HDFS-input-dir-path> <HDFS-output-dir-path>");
    }

    public int run(String[] args) throws Exception {
        if (args.length != 2) {
            usage();
            return 1;
        }

        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "HTerasort");
        job.setJarByClass(HTerasort.class);

        // MapReduce Job configuration
        job.setMapperClass(SortMapper.class);
        job.setCombinerClass(SortReducer.class);
        job.setReducerClass(SortReducer.class);

        // Number of reducers can be specified command-line
        // use -Dmapreduce.job.reduces=n
        // job.setNumReduceTasks(1);

        // Input
        FileInputFormat.addInputPath(job, new Path(args[0]));

        // Ouput
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NullWritable.class);

        return job.waitForCompletion(true) ? 0 : 1;
    }

    // runs the MapReduce job
    // timing the time it takes to complete, and writing the duration in seconds to a file
    public static void main(String[] args) throws IOException, Exception {
        long startTime = System.nanoTime();
        int res = ToolRunner.run(new Configuration(), new HTerasort(), args);
        long endTime = System.nanoTime();

        double duration = (double) (endTime - startTime) / 1000000000.0;

        PrintWriter writer = new PrintWriter("htera_duration.txt", "UTF-8");
        writer.println(duration);
        writer.close();

        System.exit(res);
    }

}