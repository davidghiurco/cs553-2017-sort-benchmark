import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.examples.terasort.TeraGen;
import org.apache.hadoop.examples.terasort.TeraValidate;

public class HTerasort {


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

    public static void main(String[] args) throws Exception {
        Configuration conf = new Configuration();
        Job job = Job.getInstance(conf, "HTerasort");
        job.setJarByClass(HTerasort.class);

        job.setMapperClass(SortMapper.class);
        job.setCombinerClass(SortReducer.class);
        job.setReducerClass(SortReducer.class);
        // job.setNumReduceTasks(0);

        job.setOutputKeyClass(Text.class);
        job.setOutputValueClass(NullWritable.class);

        FileInputFormat.addInputPath(job, new Path(args[0]));
        FileOutputFormat.setOutputPath(job, new Path(args[1]));

        job.waitForCompletion(true);

        System.out.println("Finished");
    }
}