{"structs":["struct LightInfo {\n    bool IsEnabled;\n    lowp int LightType; \/\/ 0:none 1:directional 2:point 3:spot\n    mediump vec4 LightPosition;  \/\/ in eye space\n    lowp vec3 LightDirection; \/\/ in eye space\n    mediump vec3 LightColor;\n    mediump float Attenuation;\n    mediump float SpotConsCutoff;\n    mediump float SpotExponent;\n};"],"variables":[{"precision":"highp","name":"VertexPosition","type":6,"usage":2},{"precision":"lowp","name":"MVMatrix","type":9,"usage":1}],"function":{"functionContent":"{\n    LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);\n    float lightDistance = length(LightDirection);\n    LightDirection = LightDirection \/ lightDistance; \/\/ normalize light direction\n    \n    Attenuation = 1.0 \/ (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);\n    \n    \/\/ lightDirection: current position to light position Direction\n    \/\/ MainLight.LightDirection: source light direction, ref as ConeDirection\n    float spotCos = dot(LightDirection, MainLight.LightDirection);\n    if (spotCos < MainLight.SpotConsCutoff) {\n        Attenuation = 0.0;\n    } else {\n        Attenuation *= pow(spotCos, MainLight.SpotExponent);\n    }\n}","paramNames":["LightDirection","Attenuation"],"functionID":"CEVertex_SpotLightCalculation_vec3_float","paramLocations":[["{6, 14}","{121, 14}","{142, 14}","{159, 14}","{527, 14}"],["{229, 11}","{624, 11}","{664, 11}"]]}}