#include <flutter/runtime_effect.glsl>

// Jel kapsül için custom fragment shader
// Iridescent (sedef) efekti + glow

uniform sampler2D uTexture;
uniform vec2 uResolution;
uniform float uTime;
uniform vec4 uBaseColor;   // Jel ana rengi
uniform float uGlowIntensity;

out vec4 fragColor;

// Fresnel efekti — kenarlarda daha parlak
float fresnel(vec2 uv, float power) {
  vec2 center = vec2(0.5, 0.5);
  float dist = length(uv - center);
  return pow(dist * 2.0, power);
}

// Iridescent renk kayması
vec3 iridescence(vec2 uv, float time) {
  float angle = atan(uv.y - 0.5, uv.x - 0.5);
  float shift = sin(angle * 3.0 + time * 0.8) * 0.15;
  return vec3(
    uBaseColor.r + shift,
    uBaseColor.g - shift * 0.5,
    uBaseColor.b + shift * 0.3
  );
}

void main() {
  vec2 fragCoord = FlutterFragCoord().xy;
  vec2 uv = fragCoord / uResolution;

  vec3 baseCol = iridescence(uv, uTime);

  // Fresnel glow kenarlarda
  float rim = fresnel(uv, 2.0);
  vec3 glowCol = baseCol + vec3(rim * uGlowIntensity);

  // İç kısımda şeffaflık gradyanı
  float alpha = 1.0 - rim * 0.3;

  fragColor = vec4(glowCol * uBaseColor.rgb, alpha * uBaseColor.a);
}
