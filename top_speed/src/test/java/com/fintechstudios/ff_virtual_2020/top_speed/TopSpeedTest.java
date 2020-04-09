package com.fintechstudios.ff_virtual_2020.top_speed;

import org.apache.flink.api.java.tuple.Tuple4;
import org.apache.flink.runtime.testutils.MiniClusterResourceConfiguration;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.util.TestStreamEnvironment;
import org.apache.flink.test.util.MiniClusterWithClientResource;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Nested;
import org.junit.jupiter.api.Tag;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;

import java.util.List;

import static com.google.common.truth.Truth.assertThat;

public class TopSpeedTest {

  @Nested
  @Tag(Tags.INTEGRATION)
  @ExtendWith({MiniClusterExtension.class, CollectSinkExtension.class})
  class ParseCarDataIntTest {
    @Test
    @DisplayName("should properly map a stream of car data records")
    void test_Map() throws Exception {
      StreamExecutionEnvironment env = TestStreamEnvironment.getExecutionEnvironment();

      CollectSink<Tuple4<Integer, Integer, Double, Long>> sink = new CollectSink<>();
      env
          .fromElements("\"1,2,3,4\"", "\"1,2,3,5\"", "\"1,2,3,6\"")
          .map(new TopSpeed.ParseCarData())
          .addSink(sink);

      env.execute();

      List<Tuple4<Integer, Integer, Double, Long>> data = sink.getValues();
      assertThat(data).hasSize(3);
    }
  }

  @Nested
  @Tag(Tags.UNIT)
  class ParseCarDataUnitTest {
    @Test
    @DisplayName("should parse a single record")
    void test_ParseValidRecord() {
      TopSpeed.ParseCarData mapper = new TopSpeed.ParseCarData();
      Tuple4<Integer, Integer, Double, Long> carData = mapper.map("\"1,2,3,4\"");
      assertThat(carData).isEqualTo(Tuple4.of(1, 2, 3.0, 4L));
    }
  }

  @Nested
  class CarTimestampTest {
    @Tag(Tags.UNIT)
    @Test
    @DisplayName("should return the correct timestamp")
    void test_extractTimestamp() {
      TopSpeed.CarTimestamp timestamper = new TopSpeed.CarTimestamp();
      Tuple4<Integer, Integer, Double, Long> carData = Tuple4.of(1, 2, 3.0, 4L);
      long timestamp = timestamper.extractAscendingTimestamp(carData);
      assertThat(timestamp).isEqualTo(4L);
    }
  }
}
