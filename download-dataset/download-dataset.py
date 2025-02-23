from roboflow import Roboflow
import kdl

# read config file
with open('config.kdl', 'r', encoding="utf-8") as f:
    configKdl = f.read()
config = kdl.parse(configKdl)
api_key = config["api-key"].args[0]
workspace = config["workspace"].args[0]
project = config["project"].args[0]
version = int(config["version"].args[0])

print(f'Download {workspace}/{project}/{version}...')

rf = Roboflow(api_key=api_key)
rf_workspace = rf.workspace(workspace)
rf_project = rf_workspace.project(project)
rf_version = rf_project.version(version)
output_dir = '../dataset'
rf_version.download("yolov8", output_dir)

print(f'downloaded dataset {rf_project.name}/{version} to {output_dir}')
