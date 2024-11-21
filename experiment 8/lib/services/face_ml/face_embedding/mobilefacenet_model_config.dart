import 'package:flutterface/models/model_file.dart';

import 'package:flutterface/services/face_ml/face_embedding/face_embedding_options.dart';

class MobileFaceNetModelConfig {
  final String modelPath;
  final FaceEmbeddingOptions faceEmbeddingOptions;

  MobileFaceNetModelConfig({
    required this.modelPath,
    required this.faceEmbeddingOptions,
  });
}

final MobileFaceNetModelConfig faceEmbeddingEnte = MobileFaceNetModelConfig(
  modelPath: ModelFile.faceEmbeddingEnte,
  faceEmbeddingOptions: FaceEmbeddingOptions(
    inputWidth: 112,
    inputHeight: 112,
  ),
);
