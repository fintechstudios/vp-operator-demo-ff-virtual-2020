package com.fintechstudios.ff_virtual_2020.top_speed;

import org.apache.flink.runtime.testutils.MiniClusterResourceConfiguration;
import org.apache.flink.test.util.MiniClusterWithClientResource;
import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;

public class MiniClusterExtension implements BeforeAllCallback, AfterAllCallback {
  public MiniClusterWithClientResource flinkCluster;

  @Override
  public void beforeAll(ExtensionContext context) throws Exception {
    flinkCluster = new MiniClusterWithClientResource(
        new MiniClusterResourceConfiguration.Builder()
            .setNumberSlotsPerTaskManager(2)
            .setNumberTaskManagers(1)
            .build());

    flinkCluster.before();
  }

  @Override
  public void afterAll(ExtensionContext context) throws Exception {
    flinkCluster.after();
  }
}
