package com.fintechstudios.ff_virtual_2020.top_speed;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.extension.AfterAllCallback;
import org.junit.jupiter.api.extension.AfterEachCallback;
import org.junit.jupiter.api.extension.BeforeAllCallback;
import org.junit.jupiter.api.extension.ExtensionContext;


public class CollectSinkExtension implements AfterEachCallback {
  @Override
  public void afterEach(ExtensionContext context) throws Exception {
    CollectSink.clearValues();
  }
}
