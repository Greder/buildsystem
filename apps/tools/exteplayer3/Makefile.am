AUTOMAKE_OPTIONS = subdir-objects
AM_CFLAGS = -Wall -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE64_SOURCE -DHAVE_FLV2MPEG4_CONVERTER

CXXFLAGS = -Wall

AM_CPPFLAGS = \
	-Iinclude \
	-Iexternal

lib_LTLIBRARIES = libeplayer3.la
libeplayer3_la_SOURCES = \
container/container.c \
container/container_ffmpeg.c \
manager/manager.c \
manager/audio.c \
manager/video.c \
manager/subtitle.c \
output/graphic_subtitle.c \
output/output_subtitle.c \
output/output.c \
output/linuxdvb_buffering.c \
output/linuxdvb_mipsel.c \
output/writer/common/pes.c \
output/writer/common/misc.c \
output/writer/common/writer.c \
output/writer/mipsel/writer.c \
output/writer/mipsel/aac.c \
output/writer/mipsel/ac3.c \
output/writer/mipsel/bcma.c \
output/writer/mipsel/mp3.c \
output/writer/mipsel/mjpeg.c \
output/writer/mipsel/pcm.c \
output/writer/mipsel/lpcm.c \
output/writer/mipsel/dts.c \
output/writer/mipsel/amr.c \
output/writer/mipsel/h265.c \
output/writer/mipsel/h264.c \
output/writer/mipsel/mpeg2.c \
output/writer/mipsel/mpeg4.c \
output/writer/mipsel/divx3.c \
output/writer/mipsel/vp.c \
output/writer/mipsel/wmv.c \
output/writer/mipsel/vc1.c \
playback/playback.c \
external/ffmpeg/src/bitstream.c \
external/ffmpeg/src/latmenc.c \
external/ffmpeg/src/mpeg4audio.c \
external/ffmpeg/src/xiph.c \
external/flv2mpeg4/src/m4vencode.c \
external/flv2mpeg4/src/flvdecoder.c \
external/flv2mpeg4/src/dcprediction.c \
external/flv2mpeg4/src/flv2mpeg4.c \
external/plugins/src/png.c

libeplayer3_la_LIBADD = -lswscale -ldl -lpthread -lavformat -lavcodec -lavutil -lswresample


bin_PROGRAMS = exteplayer3
exteplayer3_SOURCES = main/exteplayer.c
exteplayer3_LDADD = -leplayer3 -lpthread
exteplayer3_DEPENDENCIES = libeplayer3.la

