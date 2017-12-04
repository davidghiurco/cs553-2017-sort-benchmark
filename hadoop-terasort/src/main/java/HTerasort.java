import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.input.TextInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.lib.output.TextOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;
import org.apache.hadoop.examples.terasort.TeraInputFormat;
import org.apache.hadoop.examples.terasort.TeraOutputFormat;


public class HTerasort extends Configured implements Tool {


    public static class SortMapper extends Mapper<Object, Text, Text, NullWritable>{
        private NullWritable nullValue = NullWritable.get();

        public void map(Object key, Text value, Context context) throws IOException, InterruptedException {
            context.write(value, nullValue);
        }
    }


    public static class SortReducer extends Reducer<Text, NullWritable, Text, NullWritable> {
        private NullWritable nullValue = NullWritable.get();

        public void reduce(Text key, Iterable<NullWritable> num_occurrences, Context context) throws IOException, InterruptedException {

            for (NullWritable val : num_occurrences) {
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
        // job.setNumReduceTasks(1); // Number of reducers can be specified command-line

        // Input
        FileInputFormat.addInputPath(job, new Path(args[0]));
        job.setInputFormatClass(TeraInputFormat.class);

        // Ouput
        FileOutputFormat.setOutputPath(job, new Path(args[1]));
        job.setOutputFormatClass(TeraOutputFormat.class);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(Text.class);

        return job.waitForCompletion(true) ? 0 : 1;
    }

    public static void main(String[] args) throws Exception {
        int res = ToolRunner.run(new Configuration(), new HTerasort(), args);
        System.exit(res);
    }
}