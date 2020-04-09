package com.fintechstudios.ff_virtual_2020.top_speed;

import org.apache.flink.api.java.utils.ParameterTool;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class StandardConfiguration {
  private static final Logger LOG = LoggerFactory.getLogger(StandardConfiguration.class);

  static List<String> getPropertiesFilesFromArgs(String[] args) {
    List<String> propFiles = new ArrayList<>();

    for (int i = 0; i < args.length - 1; i += 1) {
      if (args[i].equals("--params-file")) {
        propFiles.add(args[i + 1]);
      }
    }

    return propFiles;
  }

  /**
   * Parse a {@link ParameterTool} from runtime args.
   *
   * @param args the runtime args.
   * @return the parsed params.
   * @throws IOException if a params file is specified and is not able to be loaded.
   */
  public static ParameterTool fromArgs(String[] args) throws IOException {
    ParameterTool paramTool = ParameterTool.fromArgs(args);
    for (String paramsFilePath : getPropertiesFilesFromArgs(args)) {
      LOG.info("Loading params file: {}", paramsFilePath);
      ParameterTool paramsFromFile = ParameterTool.fromPropertiesFile(paramsFilePath);
      paramTool = paramTool.mergeWith(paramsFromFile);
    }
    return paramTool;
  }
}
