{"variables":[{"precision":"highp","name":"VertexPosition","type":6,"usage":2},{"precision":"mediump","name":"MVPMatrix","type":9,"usage":1}],"function":{"functionContent":"{\n    vec4 inputColor;\n    #link CEVertex_TestFunction1(inputColor);\n    \n    #link CEVertex_TestFunction2(inputColor);\n    \n    vec3 inputColorXX = vec3(inputColor);\n    #link CEVertex_TestFunction3(inputColorXX);\n    \n    gl_Position = MVPMatrix * VertexPosition;\n}","linkFunctionDict":{"CEVertex_TestFunction2_vec4":{"paramNames":["inputColor"],"functionID":"CEVertex_TestFunction2_vec4","linkRange":"{78, 41}"},"CEVertex_TestFunction3_vec3":{"paramNames":["inputColorXX"],"functionID":"CEVertex_TestFunction3_vec3","linkRange":"{171, 43}"},"CEVertex_TestFunction1_vec4":{"paramNames":["inputColor"],"functionID":"CEVertex_TestFunction1_vec4","linkRange":"{27, 41}"}},"functionID":"main"}}