{"defaultPrecision":"LightInfo","function":{"functionContent":"{\n    LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);\n    float lightDistance = length(LightDirection);\n    LightDirection = LightDirection \/ lightDistance; \n    Attenuation = 1.0 \/ (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);\n}","paramNames":["LightDirection","Attenuation"],"functionID":"CEVertex_PointLightCalculation(vec3,float)","paramLocations":[["{6, 14}","{121, 14}","{142, 14}","{159, 14}"],["{196, 11}"]]},"structs":[{"name":"LightInfo","structID":12882754953103436571,"variables":[{"variableID":3249978979217942403,"usage":0,"name":"IsEnabled","type":"bool","arrayItemCount":1},{"usage":0,"variableID":6301559832903827976,"arrayItemCount":1,"precision":"lowp","name":"LightType","type":"int"},{"usage":0,"variableID":4161955056912782361,"arrayItemCount":1,"precision":"mediump","name":"LightPosition","type":"vec4"},{"usage":0,"variableID":44302607862241843,"arrayItemCount":1,"precision":"lowp","name":"LightDirection","type":"vec3"},{"usage":0,"variableID":1553669063202244287,"arrayItemCount":1,"precision":"mediump","name":"LightColor","type":"vec3"},{"usage":0,"variableID":2619067670163237883,"arrayItemCount":1,"precision":"mediump","name":"Attenuation","type":"float"},{"usage":0,"variableID":15220753807619384082,"arrayItemCount":1,"precision":"mediump","name":"SpotConsCutoff","type":"float"},{"usage":0,"variableID":6192175825770991975,"arrayItemCount":1,"precision":"mediump","name":"SpotExponent","type":"float"}]}],"variables":[{"usage":2,"variableID":15158389945930033855,"arrayItemCount":1,"precision":"highp","name":"VertexPosition","type":"vec4"},{"variableID":571517356123321463,"usage":1,"name":"MainLight","type":"LightInfo","arrayItemCount":1},{"usage":1,"variableID":15379621434749180082,"arrayItemCount":1,"precision":"lowp","name":"MVMatrix","type":"mat4"}]}