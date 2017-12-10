import java.io.IOException;
import java.util.Arrays;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Reducer;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.examples.terasort.TeraInputFormat;
import org.apache.hadoop.examples.terasort.TeraOutputFormat;

public class Terasort
{
  public static class TeraMapper
        extends Mapper<Text, Text, Text, Text>{
    public void map(Text key, Text value, Context context
                    ) throws IOException, InterruptedException {
      Text mykey = new Text(key);
      Text myvalue = new Text(value);
      context.write(mykey, myvalue);
    }
  }

  public static class TeraReducer
       extends Reducer<Text, Text, Text, Text> {
    public void reduce(Text key, Iterable<Text> values,
                       Context context
                       ) throws IOException, InterruptedException {
      for (Text val : values) {
        Text mykey = new Text(key);
        Text myvalue = new Text(val);
        context.write(mykey, myvalue);
      }
    }
  }

  public static void main(String[] args) throws Exception {
    Configuration conf = new Configuration();
    conf.set("mapreduce.compress.map.output", "true");
    conf.set("mapreduce.map.output.compression.codec", "org.apache.hadoop.io.compress.GzipCodec");
    Job job = Job.getInstance(conf, "terasort");
    job.setJarByClass(Terasort.class);
    job.setMapperClass(TeraMapper.class);
    job.setCombinerClass(TeraReducer.class);
    job.setReducerClass(TeraReducer.class);
    job.setOutputKeyClass(Text.class);
    job.setOutputValueClass(Text.class);
    job.setInputFormatClass(TeraInputFormat.class);
    job.setOutputFormatClass(TeraOutputFormat.class);
    job.setNumReduceTasks(2);
    TeraInputFormat.addInputPath(job, new Path(args[0]));
    FileOutputFormat.setOutputPath(job, new Path(args[1]));
    System.exit(job.waitForCompletion(true) ? 0 : 1);
  } 
} 
