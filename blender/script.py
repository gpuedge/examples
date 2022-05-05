import bpy
import sys
import os 

argv = sys.argv
argv = argv[argv.index("--") + 1:]

isGpu = False
if os.getenv('NVIDIA_VISIBLE_DEVICES') != None:
    isGpu = True

cycles_prefs = bpy.context.preferences.addons["cycles"].preferences

def configure_gpu():
    for scene in bpy.data.scenes:
        scene.cycles.device = 'GPU'
        scene.render.engine = 'CYCLES'

    # Set the device_type
    cycles_prefs.compute_device_type = argv[0]
    # Set the device and feature set
    bpy.context.scene.cycles.device = "GPU"

    # get_devices() to let Blender detects GPU device
    cycles_prefs.get_devices()
    print(cycles_prefs.compute_device_type)
    for d in cycles_prefs.devices:
        #This is unnecessary use all devices?
        d["use"] = False
        if d["type"] == 0:
            d["use"] = True
        if argv[0] == "CUDA" and d["type"] == 1:
            d["use"] = True
        if argv[0] == "OPTIX" and d["type"] == 3:
            d["use"] = True
        print(d["type"], d["name"], d["use"])

if isGpu:
    configure_gpu()

bpy.ops.wm.open_mainfile(filepath="source.blend", load_ui=False)
if isGpu:
    bpy.context.scene.cycles.device = "GPU"
bpy.context.scene.render.engine = "CYCLES"
bpy.context.scene.cycles.samples = int(argv[3])
bpy.context.scene.render.threads_mode = "FIXED"
bpy.context.scene.render.threads = int(os.getenv('NPROC', "2"))
if len(argv) >= 5 and (argv[4].startswith('ANI') or argv[4].startswith('ani')):
    print("output multi image")
    bpy.context.scene.render.image_settings.file_format = 'PNG'
    bpy.context.scene.render.filepath = "out_####"
else:
    print("output single image")
    bpy.context.scene.render.image_settings.file_format = 'PNG'
    bpy.context.scene.render.filepath = "out"
bpy.context.scene.render.resolution_x = int(argv[1])
bpy.context.scene.render.resolution_y = int(argv[2])
if len(argv) >= 5 and argv[4] and (argv[4].startswith('ANI') or argv[4].startswith('ani')):
    bpy.ops.render.render(animation = True)
else:
    bpy.ops.render.render(write_still = True)