{"defaultPrecision":"vec3","function":{"functionContent":"{\n    lowp vec3 reflectDir = normalize(-reflect(LightDirection, Normal));\n    float diffuse = max(0.0, dot(Normal, LightDirection));\n    float specular = max(0.0, dot(reflectDir, EyeDirectionOut));\n    specular = (diffuse == 0.0 || ShininessExponent == 0.0) ? 0.0 : pow(specular, ShininessExponent);\n    vec3 scatteredLight = AmbientColor * Attenuation + MainLight.LightColor * diffuse * Attenuation;\n    vec3 reflectedLight = SpecularColor * specular * Attenuation;\n    #link CEFrag_ApplyShadowMap(scatteredLight, reflectedLight);\n    inputColor = vec4(min(vec3(inputColor) * scatteredLight + reflectedLight, vec3(1.0)), 1.0);\n}","paramNames":["inputColor"],"linkFunctionDict":{"CEFrag_ApplyShadowMap(vec3,vec3)":{"paramNames":["scatteredLight","reflectedLight"],"functionID":"CEFrag_ApplyShadowMap(vec3,vec3)","linkRange":"{471, 60}"}},"functionID":"CEFrag_ApplyBaseLightEffect(vec4)","paramLocations":[["{536, 10}","{563, 10}"]]},"structs":[{"name":"LightInfo","structID":12882754953103436571,"variables":[{"variableID":3249978979217942403,"usage":0,"name":"IsEnabled","type":"bool","arrayItemCount":1},{"usage":0,"variableID":6301559832903827976,"arrayItemCount":1,"precision":"lowp","name":"LightType","type":"int"},{"usage":0,"variableID":4161955056912782361,"arrayItemCount":1,"precision":"mediump","name":"LightPosition","type":"vec4"},{"usage":0,"variableID":44302607862241843,"arrayItemCount":1,"precision":"lowp","name":"LightDirection","type":"vec3"},{"usage":0,"variableID":1553669063202244287,"arrayItemCount":1,"precision":"mediump","name":"LightColor","type":"vec3"},{"usage":0,"variableID":2619067670163237883,"arrayItemCount":1,"precision":"mediump","name":"Attenuation","type":"float"},{"usage":0,"variableID":15220753807619384082,"arrayItemCount":1,"precision":"mediump","name":"SpotConsCutoff","type":"float"},{"usage":0,"variableID":6192175825770991975,"arrayItemCount":1,"precision":"mediump","name":"SpotExponent","type":"float"}]}],"variables":[{"usage":1,"variableID":781038411599221514,"arrayItemCount":1,"precision":"mediump","name":"SpecularColor","type":"vec3"},{"usage":1,"variableID":4522050508235329674,"arrayItemCount":1,"precision":"mediump","name":"AmbientColor","type":"vec3"},{"usage":1,"variableID":10719783861868426865,"arrayItemCount":1,"precision":"mediump","name":"ShininessExponent","type":"float"},{"variableID":571517356123321463,"usage":1,"name":"MainLight","type":"LightInfo","arrayItemCount":1},{"usage":3,"variableID":9223210901354898742,"arrayItemCount":1,"precision":"lowp","name":"LightDirection","type":"vec3"},{"usage":3,"variableID":12204106266451632538,"arrayItemCount":1,"precision":"lowp","name":"EyeDirectionOut","type":"vec3"},{"usage":3,"variableID":5268517760165661644,"arrayItemCount":1,"precision":"lowp","name":"Attenuation","type":"float"},{"usage":3,"variableID":5704507788748658430,"arrayItemCount":1,"precision":"lowp","name":"Normal","type":"vec3"}]}