package com.fintechstudios.ff_virtual_2020.top_speed;

import org.apache.flink.streaming.api.functions.sink.SinkFunction;

import java.util.ArrayList;
import java.util.List;

/**
 * A basic sink that just adds output to a list.
 * @see <a href="https://ci.apache.org/projects/flink/flink-docs-stable/dev/stream/testing.html#integration-testing"/>
 */
public class CollectSink<T> implements SinkFunction<T> {
  private static final long serialVersionUID = 1L;

  // must be static
  private static final List<Object> values = new ArrayList<>();

  @Override
  public synchronized void invoke(T value, Context context) {
    values.add(value);
  }

  public static void clearValues() {
    values.clear();
  }

  /**
   * Get all the values sent to the sink.
   * @return All the sunk values.
   */
  public synchronized List<T> getValues() {
    List<T> castVals = new ArrayList<>(values.size());
    for (Object obj : values) {
      castVals.add((T) obj);
    }
    return castVals;
  }

}
