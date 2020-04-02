package com.fintechstudios.ff_sf2020.top_speed;

import org.junit.jupiter.api.AfterEach;

/**
 * A base for integration tests that rely on the static CollectSink for testing output that provide some default
 * functions for managing clean up.
 */
public interface CollectSinkTestSuite {
  @AfterEach
  default void clearSinkValues() {
    CollectSink.clearValues();
  }
}
