import raylib

from os import parentDir, `/`
const rlglHeader = currentSourcePath().parentDir()/"rlgl.h"
## *********************************************************************************************
##
##    rlgl v3.1 - raylib OpenGL abstraction layer
##
##    rlgl is a wrapper for multiple OpenGL versions (1.1, 2.1, 3.3 Core, ES 2.0) to
##    pseudo-OpenGL 1.1 style functions (rlVertex, rlTranslate, rlRotate...).
##
##    When chosing an OpenGL version greater than OpenGL 1.1, rlgl stores vertex data on internal
##    VBO buffers (and VAOs if available). It requires calling 3 functions:
##        rlglInit()  - Initialize internal buffers and auxiliar resources
##        rlglDraw()  - Process internal buffers and send required draw calls
##        rlglClose() - De-initialize internal buffers data and other auxiliar resources
##
##    CONFIGURATION:
##
##    #define GRAPHICS_API_OPENGL_11
##    #define GRAPHICS_API_OPENGL_21
##    #define GRAPHICS_API_OPENGL_33
##    #define GRAPHICS_API_OPENGL_ES2
##        Use selected OpenGL graphics backend, should be supported by platform
##        Those preprocessor defines are only used on rlgl module, if OpenGL version is
##        required by any other module, use rlGetVersion() tocheck it
##
##    #define RLGL_IMPLEMENTATION
##        Generates the implementation of the library into the included file.
##        If not defined, the library is in header only mode and can be included in other headers
##        or source files without problems. But only ONE file should hold the implementation.
##
##    #define RLGL_STANDALONE
##        Use rlgl as standalone library (no raylib dependency)
##
##    #define SUPPORT_VR_SIMULATOR
##        Support VR simulation functionality (stereo rendering)
##
##    DEPENDENCIES:
##        raymath     - 3D math functionality (Vector3, Matrix, Quaternion)
##        GLAD        - OpenGL extensions loading (OpenGL 3.3 Core only)
##
##
##    LICENSE: zlib/libpng
##
##    Copyright (c) 2014-2021 Ramon Santamaria (@raysan5)
##
##    This software is provided "as-is", without any express or implied warranty. In no event
##    will the authors be held liable for any damages arising from the use of this software.
##
##    Permission is granted to anyone to use this software for any purpose, including commercial
##    applications, and to alter it and redistribute it freely, subject to the following restrictions:
##
##      1. The origin of this software must not be misrepresented; you must not claim that you
##      wrote the original software. If you use this software in a product, an acknowledgment
##      in the product documentation would be appreciated but is not required.
##
##      2. Altered source versions must be plainly marked as such, and must not be misrepresented
##      as being the original software.
##
##      3. This notice may not be removed or altered from any source distribution.
##
## ********************************************************************************************

##  Security check in case no GRAPHICS_API_OPENGL_* defined
##  Security check in case multiple GRAPHICS_API_OPENGL_* defined

const
  SUPPORT_RENDER_TEXTURES_HINT* = true

## ----------------------------------------------------------------------------------
##  Defines and Macros
## ----------------------------------------------------------------------------------
##  Default internal render batch limits
##  Internal Matrix stack
##  Shader and material limits
##  Projection matrix culling
##  Texture parameters (equivalent to OpenGL defines)

const
  TEXTURE_WRAP_S* = 0x00002802
  TEXTURE_WRAP_T* = 0x00002803
  TEXTURE_MAG_FILTER* = 0x00002800
  TEXTURE_MIN_FILTER* = 0x00002801
  TEXTURE_ANISOTROPIC_FILTER* = 0x00003000
  FILTER_NEAREST* = 0x00002600
  FILTER_LINEAR* = 0x00002601
  FILTER_MIP_NEAREST* = 0x00002700
  FILTER_NEAREST_MIP_LINEAR* = 0x00002702
  FILTER_LINEAR_MIP_NEAREST* = 0x00002701
  FILTER_MIP_LINEAR* = 0x00002703
  WRAP_REPEAT* = 0x00002901
  WRAP_CLAMP* = 0x0000812F
  WRAP_MIRROR_REPEAT* = 0x00008370
  WRAP_MIRROR_CLAMP* = 0x00008742

##  Matrix modes (equivalent to OpenGL)

const
  MODELVIEW* = 0x00001700
  PROJECTION* = 0x00001701
  TEXTURE* = 0x00001702

##  Primitive assembly draw modes

const
  LINES* = 0x00000001
  TRIANGLES* = 0x00000004
  QUADS* = 0x00000007

## ----------------------------------------------------------------------------------
##  Types and Structures Definition
## ----------------------------------------------------------------------------------

type
  GlVersion* {.size: sizeof(cint), pure.} = enum
    OPENGL_11 = 1, OPENGL_21, OPENGL_33, OPENGL_ES_20
  FramebufferAttachType* {.size: sizeof(cint), pure.} = enum
    ATTACHMENT_COLOR_CHANNEL0 = 0, ATTACHMENT_COLOR_CHANNEL1,
    ATTACHMENT_COLOR_CHANNEL2, ATTACHMENT_COLOR_CHANNEL3,
    ATTACHMENT_COLOR_CHANNEL4, ATTACHMENT_COLOR_CHANNEL5,
    ATTACHMENT_COLOR_CHANNEL6, ATTACHMENT_COLOR_CHANNEL7, ATTACHMENT_DEPTH = 100,
    ATTACHMENT_STENCIL = 200
  FramebufferTexType* {.size: sizeof(cint), pure.} = enum
    ATTACHMENT_CUBEMAP_POSITIVE_X = 0, ATTACHMENT_CUBEMAP_NEGATIVE_X,
    ATTACHMENT_CUBEMAP_POSITIVE_Y, ATTACHMENT_CUBEMAP_NEGATIVE_Y,
    ATTACHMENT_CUBEMAP_POSITIVE_Z, ATTACHMENT_CUBEMAP_NEGATIVE_Z,
    ATTACHMENT_TEXTURE2D = 100, ATTACHMENT_RENDERBUFFER = 200




## ------------------------------------------------------------------------------------
##  Functions Declaration - Matrix operations
## ------------------------------------------------------------------------------------

proc matrixMode*(mode: cint) {.cdecl, importc: "rlMatrixMode", header: rlglHeader.}
##  Choose the current matrix to be transformed

proc pushMatrix*() {.cdecl, importc: "rlPushMatrix", header: rlglHeader.}
##  Push the current matrix to stack

proc popMatrix*() {.cdecl, importc: "rlPopMatrix", header: rlglHeader.}
##  Pop lattest inserted matrix from stack

proc loadIdentity*() {.cdecl, importc: "rlLoadIdentity", header: rlglHeader.}
##  Reset current matrix to identity matrix

proc translatef*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlTranslatef",
    header: rlglHeader.}
##  Multiply the current matrix by a translation matrix

proc rotatef*(angleDeg: cfloat; x: cfloat; y: cfloat; z: cfloat) {.cdecl,
    importc: "rlRotatef", header: rlglHeader.}
##  Multiply the current matrix by a rotation matrix

proc scalef*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlScalef",
    header: rlglHeader.}
##  Multiply the current matrix by a scaling matrix

proc multMatrixf*(matf: ptr cfloat) {.cdecl, importc: "rlMultMatrixf",
                                  header: rlglHeader.}
##  Multiply the current matrix by another matrix

proc frustum*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble;
             znear: cdouble; zfar: cdouble) {.cdecl, importc: "rlFrustum",
    header: rlglHeader.}
proc ortho*(left: cdouble; right: cdouble; bottom: cdouble; top: cdouble; znear: cdouble;
           zfar: cdouble) {.cdecl, importc: "rlOrtho", header: rlglHeader.}
proc viewport*(x: cint; y: cint; width: cint; height: cint) {.cdecl,
    importc: "rlViewport", header: rlglHeader.}
##  Set the viewport area
## ------------------------------------------------------------------------------------
##  Functions Declaration - Vertex level operations
## ------------------------------------------------------------------------------------

proc begin*(mode: cint) {.cdecl, importc: "rlBegin", header: rlglHeader.}
##  Initialize drawing mode (how to organize vertex)

proc `end`*() {.cdecl, importc: "rlEnd", header: rlglHeader.}
##  Finish vertex providing

proc vertex2i*(x: cint; y: cint) {.cdecl, importc: "rlVertex2i", header: rlglHeader.}
##  Define one vertex (position) - 2 int

proc vertex2f*(x: cfloat; y: cfloat) {.cdecl, importc: "rlVertex2f", header: rlglHeader.}
##  Define one vertex (position) - 2 float

proc vertex3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlVertex3f",
    header: rlglHeader.}
##  Define one vertex (position) - 3 float

proc texCoord2f*(x: cfloat; y: cfloat) {.cdecl, importc: "rlTexCoord2f",
                                    header: rlglHeader.}
##  Define one vertex (texture coordinate) - 2 float

proc normal3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlNormal3f",
    header: rlglHeader.}
##  Define one vertex (normal) - 3 float

proc color4ub*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl, importc: "rlColor4ub",
    header: rlglHeader.}
##  Define one vertex (color) - 4 byte

proc color3f*(x: cfloat; y: cfloat; z: cfloat) {.cdecl, importc: "rlColor3f",
    header: rlglHeader.}
##  Define one vertex (color) - 3 float

proc color4f*(x: cfloat; y: cfloat; z: cfloat; w: cfloat) {.cdecl, importc: "rlColor4f",
    header: rlglHeader.}
##  Define one vertex (color) - 4 float
## ------------------------------------------------------------------------------------
##  Functions Declaration - OpenGL equivalent functions (common to 1.1, 3.3+, ES2)
##  NOTE: This functions are used to completely abstract raylib code from OpenGL layer
## ------------------------------------------------------------------------------------

proc enableTexture*(id: cuint) {.cdecl, importc: "rlEnableTexture", header: rlglHeader.}
##  Enable texture usage

proc disableTexture*() {.cdecl, importc: "rlDisableTexture", header: rlglHeader.}
##  Disable texture usage

proc textureParameters*(id: cuint; param: cint; value: cint) {.cdecl,
    importc: "rlTextureParameters", header: rlglHeader.}
##  Set texture parameters (filter, wrap)

proc enableShader*(id: cuint) {.cdecl, importc: "rlEnableShader", header: rlglHeader.}
##  Enable shader program usage

proc disableShader*() {.cdecl, importc: "rlDisableShader", header: rlglHeader.}
##  Disable shader program usage

proc enableFramebuffer*(id: cuint) {.cdecl, importc: "rlEnableFramebuffer",
                                  header: rlglHeader.}
##  Enable render texture (fbo)

proc disableFramebuffer*() {.cdecl, importc: "rlDisableFramebuffer",
                           header: rlglHeader.}
##  Disable render texture (fbo), return to default framebuffer

proc enableDepthTest*() {.cdecl, importc: "rlEnableDepthTest", header: rlglHeader.}
##  Enable depth test

proc disableDepthTest*() {.cdecl, importc: "rlDisableDepthTest", header: rlglHeader.}
##  Disable depth test

proc enableDepthMask*() {.cdecl, importc: "rlEnableDepthMask", header: rlglHeader.}
##  Enable depth write

proc disableDepthMask*() {.cdecl, importc: "rlDisableDepthMask", header: rlglHeader.}
##  Disable depth write

proc enableBackfaceCulling*() {.cdecl, importc: "rlEnableBackfaceCulling",
                              header: rlglHeader.}
##  Enable backface culling

proc disableBackfaceCulling*() {.cdecl, importc: "rlDisableBackfaceCulling",
                               header: rlglHeader.}
##  Disable backface culling

proc enableScissorTest*() {.cdecl, importc: "rlEnableScissorTest", header: rlglHeader.}
##  Enable scissor test

proc disableScissorTest*() {.cdecl, importc: "rlDisableScissorTest",
                           header: rlglHeader.}
##  Disable scissor test

proc scissor*(x: cint; y: cint; width: cint; height: cint) {.cdecl, importc: "rlScissor",
    header: rlglHeader.}
##  Scissor test

proc enableWireMode*() {.cdecl, importc: "rlEnableWireMode", header: rlglHeader.}
##  Enable wire mode

proc disableWireMode*() {.cdecl, importc: "rlDisableWireMode", header: rlglHeader.}
##  Disable wire mode

proc setLineWidth*(width: cfloat) {.cdecl, importc: "rlSetLineWidth",
                                 header: rlglHeader.}
##  Set the line drawing width

proc getLineWidth*(): cfloat {.cdecl, importc: "rlGetLineWidth", header: rlglHeader.}
##  Get the line drawing width

proc enableSmoothLines*() {.cdecl, importc: "rlEnableSmoothLines", header: rlglHeader.}
##  Enable line aliasing

proc disableSmoothLines*() {.cdecl, importc: "rlDisableSmoothLines",
                           header: rlglHeader.}
##  Disable line aliasing

proc clearColor*(r: uint8; g: uint8; b: uint8; a: uint8) {.cdecl,
    importc: "rlClearColor", header: rlglHeader.}
##  Clear color buffer with color

proc clearScreenBuffers*() {.cdecl, importc: "rlClearScreenBuffers",
                           header: rlglHeader.}
##  Clear used screen buffers (color and depth)

proc updateBuffer*(bufferId: cint; data: pointer; dataSize: cint) {.cdecl,
    importc: "rlUpdateBuffer", header: rlglHeader.}
##  Update GPU buffer with new data

proc loadAttribBuffer*(vaoId: cuint; shaderLoc: cint; buffer: pointer; size: cint;
                      dynamic: bool): cuint {.cdecl, importc: "rlLoadAttribBuffer",
    header: rlglHeader.}
##  Load a new attributes buffer
## ------------------------------------------------------------------------------------
##  Functions Declaration - rlgl functionality
## ------------------------------------------------------------------------------------

proc init*(width: cint; height: cint) {.cdecl, importc: "rlglInit", header: rlglHeader.}
##  Initialize rlgl (buffers, shaders, textures, states)

proc close*() {.cdecl, importc: "rlglClose", header: rlglHeader.}
##  De-inititialize rlgl (buffers, shaders, textures)

proc draw*() {.cdecl, importc: "rlglDraw", header: rlglHeader.}
##  Update and draw default internal buffers

proc checkErrors*() {.cdecl, importc: "rlCheckErrors", header: rlglHeader.}
##  Check and log OpenGL error codes

proc getVersion*(): cint {.cdecl, importc: "rlGetVersion", header: rlglHeader.}
##  Returns current OpenGL version

proc checkBufferLimit*(vCount: cint): bool {.cdecl, importc: "rlCheckBufferLimit",
    header: rlglHeader.}
##  Check internal buffer overflow for a given number of vertex

proc setDebugMarker*(text: cstring) {.cdecl, importc: "rlSetDebugMarker",
                                   header: rlglHeader.}
##  Set debug marker for analysis

proc setBlendMode*(glSrcFactor: cint; glDstFactor: cint; glEquation: cint) {.cdecl,
    importc: "rlSetBlendMode", header: rlglHeader.}
##  // Set blending mode factor and equation (using OpenGL factors)

proc loadExtensions*(loader: pointer) {.cdecl, importc: "rlLoadExtensions",
                                     header: rlglHeader.}
##  Load OpenGL extensions
##  Textures data management

proc loadTexture*(data: pointer; width: cint; height: cint; format: cint;
                 mipmapCount: cint): cuint {.cdecl, importc: "rlLoadTexture",
    header: rlglHeader.}
##  Load texture in GPU

proc loadTextureDepth*(width: cint; height: cint; useRenderBuffer: bool): cuint {.cdecl,
    importc: "rlLoadTextureDepth", header: rlglHeader.}
##  Load depth texture/renderbuffer (to be attached to fbo)

proc loadTextureCubemap*(data: pointer; size: cint; format: cint): cuint {.cdecl,
    importc: "rlLoadTextureCubemap", header: rlglHeader.}
##  Load texture cubemap

proc updateTexture*(id: cuint; offsetX: cint; offsetY: cint; width: cint; height: cint;
                   format: cint; data: pointer) {.cdecl, importc: "rlUpdateTexture",
    header: rlglHeader.}
##  Update GPU texture with new data

proc getGlTextureFormats*(format: cint; glInternalFormat: ptr cuint;
                         glFormat: ptr cuint; glType: ptr cuint) {.cdecl,
    importc: "rlGetGlTextureFormats", header: rlglHeader.}
##  Get OpenGL internal formats

proc unloadTexture*(id: cuint) {.cdecl, importc: "rlUnloadTexture", header: rlglHeader.}
##  Unload texture from GPU memory

proc generateMipmaps*(texture: ptr Texture2D) {.cdecl, importc: "rlGenerateMipmaps",
    header: rlglHeader.}
##  Generate mipmap data for selected texture

proc readTexturePixels*(texture: Texture2D): pointer {.cdecl,
    importc: "rlReadTexturePixels", header: rlglHeader.}
##  Read texture pixel data

proc readScreenPixels*(width: cint; height: cint): ptr uint8 {.cdecl,
    importc: "rlReadScreenPixels", header: rlglHeader.}
##  Read screen pixel data (color buffer)
##  Framebuffer management (fbo)

proc loadFramebuffer*(width: cint; height: cint): cuint {.cdecl,
    importc: "rlLoadFramebuffer", header: rlglHeader.}
##  Load an empty framebuffer

proc framebufferAttach*(fboId: cuint; texId: cuint; attachType: cint; texType: cint) {.
    cdecl, importc: "rlFramebufferAttach", header: rlglHeader.}
##  Attach texture/renderbuffer to a framebuffer

proc framebufferComplete*(id: cuint): bool {.cdecl, importc: "rlFramebufferComplete",
    header: rlglHeader.}
##  Verify framebuffer is complete

proc unloadFramebuffer*(id: cuint) {.cdecl, importc: "rlUnloadFramebuffer",
                                  header: rlglHeader.}
##  Delete framebuffer from GPU
##  Vertex data management

proc loadMesh*(mesh: ptr Mesh; dynamic: bool) {.cdecl, importc: "rlLoadMesh",
    header: rlglHeader.}
##  Upload vertex data into GPU and provided VAO/VBO ids

proc updateMesh*(mesh: Mesh; buffer: cint; count: cint) {.cdecl,
    importc: "rlUpdateMesh", header: rlglHeader.}
##  Update vertex or index data on GPU (upload new data to one buffer)

proc updateMeshAt*(mesh: Mesh; buffer: cint; count: cint; index: cint) {.cdecl,
    importc: "rlUpdateMeshAt", header: rlglHeader.}
##  Update vertex or index data on GPU, at index

proc drawMesh*(mesh: Mesh; material: Material; transform: Matrix) {.cdecl,
    importc: "rlDrawMesh", header: rlglHeader.}
##  Draw a 3d mesh with material and transform

proc drawMeshInstanced*(mesh: Mesh; material: Material; transforms: ptr Matrix;
                       count: cint) {.cdecl, importc: "rlDrawMeshInstanced",
                                    header: rlglHeader.}
##  Draw a 3d mesh with material and transform

proc unloadMesh*(mesh: Mesh) {.cdecl, importc: "rlUnloadMesh", header: rlglHeader.}
##  Unload mesh data from CPU and GPU
##  NOTE: There is a set of shader related functions that are available to end user,
##  to avoid creating function wrappers through core module, they have been directly declared in raylib.h

converter GlVersionToInt*(self: GlVersion): cint = self.cint
converter FramebufferAttachTypeToInt*(self: FramebufferAttachType): cint = self.cint
converter FramebufferTexTypeToInt*(self: FramebufferTexType): cint = self.cint

template begin*(mode: cint; body: untyped) =
  begin(mode)
  block:
    body
  `end`()

