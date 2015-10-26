

struct LightInfo {
    bool IsEnabled;
    lowp int LightType; // 0:none 1:directional 2:point 3:spot
    mediump vec4 LightPosition;  // in eye space
    lowp vec3 LightDirection; // in eye space
    mediump vec3 LightColor;
    mediump float Attenuation;
    mediump float SpotConsCutoff;
    mediump float SpotExponent;
};
uniform LightInfo MainLight;

attribute highp vec4 VertexPosition;
uniform lowp mat4 MVMatrix;

void PointLightCalculation(vec3 LightDirection, float Attenuation) {
    LightDirection = vec3(MainLight.LightPosition) - vec3(MVMatrix * VertexPosition);
    float lightDistance = length(LightDirection);
    LightDirection = LightDirection / lightDistance; // normalize light direction
    
    Attenuation = 1.0 / (1.0 + MainLight.Attenuation * lightDistance + MainLight.Attenuation * lightDistance * lightDistance);
}
